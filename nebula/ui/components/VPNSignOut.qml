/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.0

import Mozilla.VPN 1.0

VPNFooterLink {
    property var popMainView: false

    //% "Sign out"
    labelText: qsTrId("vpn.main.signOut2")
    fontName: VPNTheme.theme.fontBoldFamily
    linkColor: VPNTheme.theme.redButton
    onClicked: () => {
                    VPNController.logout();
                    if(popMainView) mainStackView.pop();
               }
}
