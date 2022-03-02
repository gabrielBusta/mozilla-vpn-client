/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef TUTORIAL_H
#define TUTORIAL_H

#include "itempicker.h"

#include <QTimer>

class Tutorial final : public ItemPicker {
  Q_OBJECT
  Q_PROPERTY(bool playing READ isPlaying NOTIFY playingChanged)
  Q_PROPERTY(bool tooltipShown MEMBER m_tooltipShown NOTIFY tooltipShownChanged)

 public:
  static Tutorial* instance();

  ~Tutorial();

  Q_INVOKABLE void play(const QString& fileName);
  Q_INVOKABLE void stop();
  Q_INVOKABLE void allowItem(const QString& objectName);

  bool isPlaying() const { return !m_steps.isEmpty(); }

 private:
  explicit Tutorial(QObject* parent);

  bool itemPicked(const QStringList& list) override;

  void processNextOp();

  // Return true if there are no operations left.
  bool maybeStop();

  void setTooltipShown(bool shown);

 signals:
  void playingChanged();
  void tooltipNeeded(const QString& tooltipText, const QRectF& itemRect);
  void tooltipShownChanged();

 private:
  struct Op {
    QString m_element;
    QString m_stringId;
  };

  QList<Op> m_steps;
  QStringList m_allowedItems;
  QTimer m_timer;
  bool m_tooltipShown = false;
};

#endif  // TUTORIAL_H
