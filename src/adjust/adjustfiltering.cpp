/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "adjustfiltering.h"
#include "constants.h"

#include <algorithm>

const QVector<QString> allowList{
    "adid",
    "android_uuid",
    "app_token",
    "att_status",
    "attribution_deeplink",
    "bundle_id",
    "created_at",
    "device_type",
    "environment",
    "event_token",
    "google_play_instant",
    "gps_adid",
    "idfv",
    "needs_response_details",
    "os_name",
    "os_version",
    "package_name",
    "reference_tag",
    "referrer",
    "referrer_api",
    "sent_at",
    "source",
    "tracking_enabled",
    "zone_offset",
};

struct DenyParam {
  QString m_paramName;
  QString m_defaultValue;
};

const QVector<DenyParam> denyList{
    {"api_level", "29"},
    {"app_name", "default"},
    {"app_version", "2"},
    {"app_version_short", "2"},
    {"base_amount", "0"},
    {"connectivity_type", "0"},
    {"country", "US"},
    {"cpu_type", "arm64"},
    {"device_manufacturer", "xxxxx"},
    {"display_height", "0"},
    {"display_width", "0"},
    {"engagement_type", "0"},
    {"event_buffering_enabled", "0"},
    {"event_cost_id", "xxxxx"},
    {"gps_adid_attempt", "1"},
    {"gps_adid_lower_md5", "0"},
    {"gps_adid_lower_sha1", "0"},
    {"gps_adid_upper_md5", "0"},
    {"gps_adid_upper_sha1", "0"},
    {"hardware_name", "xxxx"},
    {"ios_uuid", "xxxxx"},
    {"language", "en"},
    {"manufacturer", "default"},
    {"mcc", "0"},
    {"mnc", "0"},
    {"network_type", "0"},
    {"nonce", "0"},
    {"os_build", "xxxxx"},
    {"platform", "default"},
    {"random_user_id", "xxxxx"},
    {"region", "xxxxx"},
    {"screen_density", "0"},
    {"screen_format", "0"},
    {"screen_size", "0"},
    {"session_count", "1"},
    {"session_length", "0"},
    {"store_name", "xxxxx"},
    {"terms_signed", "0"},
    {"time_spent", "0"},
    {"tracker_token", "xxxxx"},
    {"ui_mode", "0"},
};

struct MirrorParam {
  QString m_paramName;
  QString m_mirrorParamName;
  QString m_defaultValue;
};

const QVector<MirrorParam> mirrorList{
    {"device_name", "device_type", Constants::PLATFORM_NAME},
    {"installed_at", "created_at", "0"},
    {"updated_at", "created_at", "0"},
};

// static
QUrlQuery AdjustFiltering::filterParameters(QUrlQuery& parameters,
                                            QStringList& unknownParameters) {
  QUrlQuery newParameters;

#ifdef MVPN_DEBUG
  // We use the binary-search algorithm. The arrays must be alphabetically
  // sorted. Let's check this in debug builds.

  for (int i = 1; i < allowList.length(); ++i)
    Q_ASSERT(allowList[i] > allowList[i - 1]);

  for (int i = 1; i < denyList.length(); ++i)
    Q_ASSERT(denyList[i].m_paramName > denyList[i - 1].m_paramName);

  for (int i = 1; i < mirrorList.length(); ++i) {
    Q_ASSERT(mirrorList[i].m_paramName > mirrorList[i - 1].m_paramName);
    // Only allowed params can be mirrored.
    Q_ASSERT(allowList.contains(mirrorList[i].m_paramName));
  }
#endif

  for (const QPair<QString, QString>& parameter : parameters.queryItems()) {
    if (std::binary_search(allowList.begin(), allowList.end(),
                           parameter.first)) {
      newParameters.addQueryItem(parameter.first, parameter.second);
      continue;
    }

    const DenyParam* denyParam = std::lower_bound(
        denyList.begin(), denyList.end(), parameter.first,
        [](const DenyParam& data, const QString& value) -> bool {
          return data.m_paramName < value;
        });
    if (denyParam && denyParam != denyList.end() &&
        denyParam->m_paramName == parameter.first) {
      newParameters.addQueryItem(parameter.first, denyParam->m_defaultValue);
      continue;
    }

    const MirrorParam* mirrorParam = std::lower_bound(
        mirrorList.begin(), mirrorList.end(), parameter.first,
        [](const MirrorParam& data, const QString& value) -> bool {
          return data.m_paramName < value;
        });
    if (mirrorParam && mirrorParam != mirrorList.end() &&
        mirrorParam->m_paramName == parameter.first) {
      bool found = false;
      for (const QPair<QString, QString>& otherParameter :
           parameters.queryItems()) {
        if (mirrorParam->m_mirrorParamName == otherParameter.first) {
          newParameters.addQueryItem(parameter.first, otherParameter.second);
          found = true;
          break;
        }
      }

      if (!found) {
        newParameters.addQueryItem(parameter.first,
                                   mirrorParam->m_defaultValue);
      }

      continue;
    }

    unknownParameters.append(parameter.first);
  }

  return newParameters;
}
