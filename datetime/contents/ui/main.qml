import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.calendar as PlasmaCalendar
import "../code/format.js" as Fmt

PlasmoidItem {
    id: root

    property date now: new Date()

    readonly property string dateText: Fmt.format(now, Plasmoid.configuration.dateFormat)
    readonly property string timeText: Fmt.format(now, Plasmoid.configuration.timeFormat)
    readonly property string separator: Plasmoid.configuration.separator

    // Always show the one-line label, on panels and on the desktop.
    preferredRepresentation: compactRepresentation

    toolTipMainText: Qt.formatDate(now, Qt.locale().dateFormat(Locale.LongFormat))
    toolTipSubText: Qt.formatTime(now, Qt.locale().timeFormat(Locale.LongFormat))

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    compactRepresentation: MouseArea {
        id: compact

        readonly property bool inPanel: Plasmoid.location === PlasmaCore.Types.TopEdge
            || Plasmoid.location === PlasmaCore.Types.BottomEdge
            || Plasmoid.location === PlasmaCore.Types.LeftEdge
            || Plasmoid.location === PlasmaCore.Types.RightEdge

        // A configured size wins; otherwise the theme size (doubled on the desktop).
        readonly property real pointSize: Plasmoid.configuration.fontSize > 0
            ? Plasmoid.configuration.fontSize
            : Kirigami.Theme.defaultFont.pointSize * (inPanel ? 1 : 2)

        Layout.minimumWidth: line.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.preferredWidth: Layout.minimumWidth
        Layout.minimumHeight: line.implicitHeight

        hoverEnabled: true
        onClicked: root.expanded = !root.expanded

        Row {
            id: line
            anchors.centerIn: parent
            spacing: Plasmoid.configuration.gap

            PlasmaComponents.Label {
                visible: text.length > 0
                text: root.dateText
                font.bold: Plasmoid.configuration.boldText
                font.pointSize: compact.pointSize
            }
            PlasmaComponents.Label {
                visible: text.length > 0 && root.dateText.length > 0 && root.timeText.length > 0
                text: root.separator
                font.bold: Plasmoid.configuration.boldText
                font.pointSize: compact.pointSize
            }
            PlasmaComponents.Label {
                visible: text.length > 0
                text: root.timeText
                font.bold: Plasmoid.configuration.boldText
                font.pointSize: compact.pointSize
            }
        }
    }

    // Changes only when the day changes, so the calendar isn't reset every second.
    readonly property string todayKey: Qt.formatDate(now, "yyyy-MM-dd")

    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 26
        Layout.minimumHeight: Kirigami.Units.gridUnit * 22
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(root.now, Qt.locale().timeFormat(Locale.LongFormat))
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 2
        }
        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: Fmt.format(root.now, "dddd d[th] MMMM yyyy")
        }

        PlasmaCalendar.MonthView {
            id: monthView
            Layout.fillWidth: true
            Layout.fillHeight: true
            borderOpacity: 0.25
            showWeekNumbers: Plasmoid.configuration.showWeekNumbers
            today: new Date()

            Connections {
                target: root
                function onTodayKeyChanged() { monthView.today = new Date() }
                // Jump back to the current month each time the popup opens.
                function onExpandedChanged() { if (root.expanded) monthView.resetToToday() }
            }
        }
    }
}
