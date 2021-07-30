

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import QtQuick 2.5

import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import Mozilla.VPN 1.0
import "../components"
import "../components/forms"
import "../themes/themes.js" as Theme

Item {
    id: feedbackRoot

    function sendFeedback(appRating, category, message) {
        VPN.submitFeedback(message, appRating, category);
        feedbackStackView.push(thankYouView)
    }

    VPNMenu {
        id: menu
        title: qsTrId("vpn.settings.giveFeedback")
        isSettingsView: true
    }

    StackView {
        id: feedbackStackView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: menu.bottom
        initialItem: appRatingView
    }

    Component {
        id: appRatingView

        Item {
            id: root
            ButtonGroup {
                id: btnGroup
                buttons: row.children
            }

            ColumnLayout {
                id: col
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Theme.windowMargin * 2
                anchors.margins: Theme.windowMargin * 2
                anchors.topMargin: window.fullscreenRequired() ? Theme.contentTopMarginMobile : Theme.contentTopMarginDesktop

                VPNBoldLabel {
                    //% "How would you describe your Mozilla VPN experience so far?"
                    text: qsTrId("vpn.feedbackForm.ratingHeadline")
                    lineHeight: 24
                    lineHeightMode: Text.FixedHeight
                    Layout.preferredWidth: parent.width
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignBottom
                }

                ColumnLayout {
                    spacing: 8

                    RowLayout {
                        id: row
                        Layout.preferredHeight: Theme.rowHeight

                        VPNFeedbackRadioDelegate {
                            //% "Very poor"
                            Accessible.name: qsTrId("vpn.feedbackForm.veryPoor")
                            iconSource: "../resources/faces/veryPoor.svg"
                            value: 1
                        }
                        VPNVerticalSpacer {
                           Layout.preferredHeight: 1
                           Layout.fillWidth: true
                        }

                        VPNFeedbackRadioDelegate {
                            //% "Poor"
                            Accessible.name: qsTrId("vpn.feedbackForm.poor")
                            iconSource: "../resources/faces/poor.svg"
                            value: 2
                        }

                        VPNVerticalSpacer {
                           Layout.preferredHeight: 1
                           Layout.fillWidth: true
                        }

                        VPNFeedbackRadioDelegate {
                            //% "Average"
                            Accessible.name: qsTrId("vpn.feedbackForm.average")
                            iconSource: "../resources/faces/average.svg"
                            value: 3
                        }

                        VPNVerticalSpacer {
                           Layout.preferredHeight: 1
                           Layout.fillWidth: true
                        }

                        VPNFeedbackRadioDelegate {
                            //% "Good"
                            Accessible.name: qsTrId("vpn.feedbackForm.good")
                            iconSource: "../resources/faces/good.svg"
                            value: 4
                        }

                        VPNVerticalSpacer {
                           Layout.preferredHeight: 1
                           Layout.fillWidth: true
                        }

                        VPNFeedbackRadioDelegate {
                            //% "Very good"
                            Accessible.name: qsTrId("vpn.feedbackForm.veryGood")
                            iconSource: "../resources/faces/veryGood.svg"
                            value: 5
                        }
                    }
                    RowLayout {
                        VPNInterLabel {
                            Layout.alignment: Qt.AlignLeft
                            horizontalAlignment: Qt.AlignLeft
                            text: qsTrId("vpn.feedbackForm.veryPoor")
                            Layout.fillWidth: true
                            color: Theme.fontColor
                        }
                        VPNInterLabel {
                            Layout.alignment: Qt.AlignRight
                            horizontalAlignment: Qt.AlignRight
                            text: qsTrId("vpn.feedbackForm.veryGood")
                            Layout.fillWidth: true
                            color: Theme.fontColor
                        }
                    }
                }
            }

            VPNButton {
                //% "Continue"
                text: qsTrId("vpn.feedbackForm.continue")
                onClicked: {
                    if (btnGroup.checkedButton.value === null) {
                        // This should not happen.
                        return;
                    }

                    if (btnGroup.checkedButton.value >= 5) {
                        feedbackRoot.sendFeedback(btnGroup.checkedButton.value, 0, "");
                        feedbackStackView.push(thankYouView);
                        return;
                    }

                    feedbackStackView.push(feedbackFormView, {
                                               "appRating": btnGroup.checkedButton.value
                                           })
                }

                anchors.horizontalCenter: parent.horizontalCenter
                Component.onCompleted: {
                    if (window.fullscreenRequired()) {
                        anchors.bottom = parent.bottom;
                        anchors.bottomMargin = Theme.windowMargin * 4;
                        return;
                    }
                    anchors.top = col.bottom;
                    anchors.topMargin = Theme.windowMargin * 2;

                }

                enabled: btnGroup.checkedButton !== null
                opacity: enabled ? 1 : .5
                width: col.width
                Behavior on opacity {
                    PropertyAnimation {
                        duration: 100
                    }
                }
            }
        }
    }

    Component {
        id: feedbackFormView
        VPNFlickable {
            id: vpnFlickable
            property var appRating
            property var feedbackCategory
            flickContentHeight: col.childrenRect.height
            interactive: flickContentHeight > height

            Rectangle {
                anchors.fill: parent
                color: Theme.bgColor
            }

            ColumnLayout {
                id: col

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Theme.windowMargin
                anchors.margins: Theme.windowMargin * 2
                anchors.topMargin: window.fullscreenRequired() ? Theme.contentTopMarginMobile : Theme.contentTopMarginDesktop


                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: parent.width

                    spacing: 24

                    VPNBoldLabel {
                        //% "We’re sorry to hear you’ve had a poor experience. Please let us know how we can improve."
                        property string lowRatingResponse: qsTrId("vpn.feedbackForm.lowRatingResponse")

                        //% "We’d love to know what we can do to improve Mozilla VPN. Please share any specific feedback here."
                        property string averageToHighRatingResponse: qsTrId("vpn.feedbackForm.averageToHighRatingResponse")
                        text: appRating >= 3 ? averageToHighRatingResponse : lowRatingResponse
                        lineHeight: 24
                        lineHeightMode: Text.FixedHeight
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                        Layout.fillWidth: true
                    }

                    VPNComboBox {
                        id: dropDown
                         //% "Choose a Category"
                        placeholderText: qsTrId("vpn.feedbackForm.chooseCategory")

                        model: VPNFeedbackCategoryModel
                    }

                    VPNTextArea {
                        id: textArea
                        //% "Enter feedback…"
                        placeholderText: qsTrId("vpn.feedbackForm.textAreaPlaceholder")
                    }
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    spacing: 24

                    VPNVerticalSpacer {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 16
                        Layout.fillHeight: !window.fullscreenRequired()
                    }

                    Column {
                        spacing: 0
                        Layout.fillWidth: true


                        VPNTextBlock {
                            font.pixelSize: Theme.fontSize
                            horizontalAlignment: Text.AlignHCenter
                            //% "When you submit feedback, Mozilla VPN will collect technical and interaction data, including your IP address, to help us improve. This data won’t be associated with your Firefox account."
                            text: qsTrId("vpn.feedback.privacyDisclaimer")
                            width:parent.width
                        }

                        VPNLinkButton {
                            //% "Mozilla VPN Privacy Notice"
                            labelText: qsTrId("vpn.feedbackForm.privacyNoticeLink")
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: VPN.openLink(VPN.LinkPrivacyNotice)
                            width: parent.width
                        }
                    }

                    ColumnLayout {
                        spacing: Theme.windowMargin

                        VPNButton {
                             //% "Submit"
                            text: qsTrId("vpn.feedbackform.submit")
                            onClicked: feedbackRoot.sendFeedback(appRating, dropDown.currentValue, textArea.userEntry);
                            enabled: dropDown.currentValue != null
                            opacity: enabled ? 1 : .5
                            Layout.preferredHeight: Theme.rowHeight
                            Layout.fillWidth: true
                            width: undefined
                            height: undefined
                            Behavior on opacity {
                                PropertyAnimation {
                                    duration: 100
                                }
                            }
                        }
                        VPNLinkButton {
                            //% "Skip"
                            labelText: qsTrId("vpn.feedbackForm.skip")
                            Layout.preferredHeight: Theme.rowHeight
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: feedbackRoot.sendFeedback(appRating, 0, "");
                            implicitHeight: Theme.rowHeight

                        }
                    }
                    VPNVerticalSpacer {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: Theme.rowHeight * 2
                        Layout.maximumHeight: Layout.minimumHeight
                    }
                }
            }
        }
    }

    Component {
        id: thankYouView
        Item {
            ColumnLayout {
                anchors.top: parent.top
                anchors.topMargin: window.height * .10
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(Theme.maxHorizontalContentWidth, parent.width - Theme.windowMargin * 4)
                spacing: 24
                VPNPanel {
                    logo: "../resources/heart-check.svg"
                    //% "Thank you!"
                    logoTitle: qsTrId("vpn.feedbackForm.thankyou")
                    //% "We appreciate your feedback. You’re helping us improve Mozilla VPN."
                    logoSubtitle: qsTrId("vpn.feedbackForm.thankyouSubtitle")
                    anchors.horizontalCenter: undefined
                    Layout.fillWidth: true
                }
                VPNButton {
                    //% "Done"
                   text: qsTrId("vpn.feedbackform.done")
                   Layout.fillWidth: true
                   Layout.preferredHeight: Theme.rowHeight
                   onClicked: stackview.pop(StackView.Immediate)
                }
            }
        }
    }
}
