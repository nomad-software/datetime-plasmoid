import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "../code/format.js" as Fmt

KCM.SimpleKCM {
    id: page

    property alias cfg_dateFormat: dateField.text
    property alias cfg_timeFormat: timeField.text
    property alias cfg_separator: separatorField.text
    property alias cfg_boldText: boldCheck.checked
    property alias cfg_gap: gapSpin.value
    property alias cfg_fontSize: fontSizeSpin.value
    property alias cfg_showWeekNumbers: weekNumbersCheck.checked

    property date now: new Date()
    // The field that clicked format codes are inserted into.
    property var targetField: dateField

    readonly property var dateCodes: [
        { code: "d",    desc: i18n("Day of month") },
        { code: "dd",   desc: i18n("Day of month, two digits") },
        { code: "[th]", desc: i18n("Day suffix: st, nd, rd, th (use after d, e.g. d[th])") },
        { code: "ddd",  desc: i18n("Weekday, short") },
        { code: "dddd", desc: i18n("Weekday, full") },
        { code: "M",    desc: i18n("Month number") },
        { code: "MM",   desc: i18n("Month number, two digits") },
        { code: "MMM",  desc: i18n("Month name, short") },
        { code: "MMMM", desc: i18n("Month name, full") },
        { code: "yy",   desc: i18n("Year, two digits") },
        { code: "yyyy", desc: i18n("Year, four digits") }
    ]

    readonly property var timeCodes: [
        { code: "H",    desc: i18n("Hour, 24-hour clock") },
        { code: "HH",   desc: i18n("Hour, 24-hour clock, two digits") },
        { code: "h",    desc: i18n("Hour, 12-hour clock (use with AP)") },
        { code: "hh",   desc: i18n("Hour, 12-hour clock, two digits") },
        { code: "mm",   desc: i18n("Minutes, two digits") },
        { code: "ss",   desc: i18n("Seconds, two digits") },
        { code: "AP",   desc: i18n("AM / PM") },
        { code: "ap",   desc: i18n("am / pm") }
    ]

    function insertCode(code) {
        const f = page.targetField;
        const pos = f.cursorPosition;
        f.insert(pos, code);
        f.forceActiveFocus();
        f.cursorPosition = pos + code.length;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: page.now = new Date()
    }

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            Row {
                id: preview
                Kirigami.FormData.label: i18n("Preview:")
                spacing: gapSpin.value

                readonly property string dateText: Fmt.format(page.now, dateField.text)
                readonly property string timeText: Fmt.format(page.now, timeField.text)
                readonly property real pointSize: fontSizeSpin.value > 0
                    ? fontSizeSpin.value : Kirigami.Theme.defaultFont.pointSize

                QQC2.Label {
                    visible: text.length > 0
                    text: preview.dateText
                    font.bold: boldCheck.checked
                    font.pointSize: preview.pointSize
                }
                QQC2.Label {
                    visible: text.length > 0 && preview.dateText.length > 0 && preview.timeText.length > 0
                    text: separatorField.text
                    font.bold: boldCheck.checked
                    font.pointSize: preview.pointSize
                }
                QQC2.Label {
                    visible: text.length > 0
                    text: Fmt.smallAmPm(preview.timeText, preview.pointSize, 0.6)
                    textFormat: Text.RichText
                    font.bold: boldCheck.checked
                    font.pointSize: preview.pointSize
                }
            }

            Item { Kirigami.FormData.isSection: true }

            RowLayout {
                Kirigami.FormData.label: i18n("Date format:")
                QQC2.TextField {
                    id: dateField
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 12
                    placeholderText: i18n("empty = hide date")
                    onActiveFocusChanged: if (activeFocus) page.targetField = dateField
                }
                QQC2.ComboBox {
                    model: ["ddd d MMM yyyy", "dddd d MMMM yyyy", "dddd d[th] MMMM yyyy",
                            "dddd, MMMM d[th] yyyy", "ddd d[th] MMM", "dd/MM/yyyy", "yyyy-MM-dd", "MM/dd/yyyy", "d MMM"]
                    currentIndex: -1
                    displayText: i18n("Presets")
                    onActivated: dateField.text = currentText
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Time format:")
                QQC2.TextField {
                    id: timeField
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 12
                    placeholderText: i18n("empty = hide time")
                    onActiveFocusChanged: if (activeFocus) page.targetField = timeField
                }
                QQC2.ComboBox {
                    model: ["HH:mm", "HH:mm:ss", "h:mm AP", "h:mm:ss AP"]
                    currentIndex: -1
                    displayText: i18n("Presets")
                    onActivated: timeField.text = currentText
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Gap between date and time:")
                QQC2.SpinBox {
                    id: gapSpin
                    from: 0
                    to: 200
                }
                QQC2.Label { text: i18n("pixels") }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Separator text:")
                QQC2.TextField {
                    id: separatorField
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 6
                    placeholderText: i18n("none")
                }
                QQC2.Label {
                    text: i18n("optional, e.g. | or •")
                    opacity: 0.7
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Font size:")
                QQC2.SpinBox {
                    id: fontSizeSpin
                    from: 0
                    to: 200
                    textFromValue: (value, locale) => value === 0 ? i18n("Default") : value + " pt"
                    valueFromText: (text, locale) => parseInt(text) || 0
                }
                QQC2.Label {
                    text: i18n("0 = Plasma default")
                    opacity: 0.7
                }
            }

            QQC2.CheckBox {
                id: boldCheck
                Kirigami.FormData.label: i18n("Text:")
                text: i18n("Bold")
            }

            QQC2.CheckBox {
                id: weekNumbersCheck
                Kirigami.FormData.label: i18n("Calendar:")
                text: i18n("Show week numbers")
            }
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Information
            text: i18n("Click a code below to add it to the <b>%1</b> field at the cursor. "
                     + "Anything else you type (spaces, / - : , .) appears as-is. "
                     + "Put words in single quotes, e.g. <b>'Week'</b>, so their letters aren't read as codes.",
                     page.targetField === timeField ? i18n("Time format") : i18n("Date format"))
        }

        Kirigami.Heading {
            level: 3
            text: i18n("Date codes")
        }
        CodeTable { codes: page.dateCodes }

        Kirigami.Heading {
            level: 3
            text: i18n("Time codes")
        }
        CodeTable { codes: page.timeCodes }
    }

    component CodeTable: GridLayout {
        property var codes: []
        Layout.fillWidth: true
        columns: 3
        columnSpacing: Kirigami.Units.largeSpacing
        rowSpacing: Kirigami.Units.smallSpacing

        QQC2.Label { text: i18n("Code"); font.bold: true }
        QQC2.Label { text: i18n("Meaning"); font.bold: true }
        QQC2.Label { text: i18n("Now"); font.bold: true }

        Repeater {
            model: parent.codes
            delegate: QQC2.Button {
                required property var modelData
                Layout.row: index + 1
                Layout.column: 0
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4
                text: modelData.code
                required property int index
                font.family: "monospace"
                onClicked: page.insertCode(modelData.code)
                QQC2.ToolTip.text: i18n("Insert \"%1\"", modelData.code)
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            }
        }
        Repeater {
            model: parent.codes
            delegate: QQC2.Label {
                required property var modelData
                required property int index
                Layout.row: index + 1
                Layout.column: 1
                Layout.fillWidth: true
                text: modelData.desc
            }
        }
        Repeater {
            model: parent.codes
            delegate: QQC2.Label {
                required property var modelData
                required property int index
                Layout.row: index + 1
                Layout.column: 2
                text: Fmt.format(page.now, modelData.code)
                opacity: 0.8
            }
        }
    }
}
