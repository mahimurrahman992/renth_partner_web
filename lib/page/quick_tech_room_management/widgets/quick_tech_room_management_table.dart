import '../../../consts/consts.dart';
import '../../room_list/quick_tech_room_screen.dart' show showDeleteRoomDialog;

class QuickTechRoomManagementTable extends StatefulWidget {
  const QuickTechRoomManagementTable({super.key});

  @override
  State<QuickTechRoomManagementTable> createState() =>
      _QuickTechRoomManagementTableState();
}

class _QuickTechRoomManagementTableState
    extends State<QuickTechRoomManagementTable> {
  final controller = locator.get<QuickTechRoomController>();

  int get _effectivePropertyId {
    final raw = GetStorage().read(StorageKeys.selectedPropertyId);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRoomRecords(propertyId: _effectivePropertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: mainColor),
          ),
        );
      }

      final rooms = controller.roomList.value.propertyRoomRecords ?? [];

      return LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          // ---------------- EMPTY ----------------
          if (rooms.isEmpty) {
            if (isMobile) return _mobileEmpty();
            return _premiumEmpty(constraints.maxWidth);
          }

          // ---------------- TABLE ----------------
          final table = _buildTable(
            context: context,
            rooms: rooms,
            isMobile: isMobile,
            minWidth: constraints.maxWidth,
          );

          if (isMobile) return table;

          // Tablet / Desktop: full width card
          return Container(
            width: double.infinity,
            decoration: _cardDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: table,
            ),
          );
        },
      );
    });
  }

  // ===========================================================================
  // TABLE
  // ===========================================================================

  Widget _buildTable({
    required BuildContext context,
    required List rooms,
    required bool isMobile,
    required double minWidth,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerTheme: const DividerThemeData(
              color: Color(0xFFE0E0E0),
              thickness: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isMobile ? 12 : 0),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFFDD835)),
              dividerThickness: 1,
              dataRowColor: WidgetStateProperty.all(Colors.white),
              columnSpacing: isMobile ? 20 : 32,
              horizontalMargin: isMobile ? 12 : 24,
              headingRowHeight: isMobile ? null : 56,
              dataRowMinHeight: isMobile ? 76 : 68,
              dataRowMaxHeight: isMobile ? 84 : 76,
              columns: _columns(isMobile),
              rows: rooms.map<DataRow>((room) {
                final int? roomId = room.propertyRoom?.id ?? room.id;
                final int roomTypeId =
                    room.roomTypeId ?? room.roomType?.id ?? 0;
                final int propId = room.propertyId ?? _effectivePropertyId;
                final String roomName =
                    room.propertyRoom?.roomName ??
                    room.roomType?.name ??
                    'this room';

                return DataRow(
                  cells: [
                    // ROOM TYPE (mobile e name er niche View Details)
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isMobile ? 130 : 260,
                              ),
                              child: Text(
                                room.roomType?.name ?? "-",
                                maxLines: isMobile ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                                style: QuickTechAppTextStyle.bodyText4()
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (isMobile) ...[
                              const SizedBox(height: 8),
                              _detailsButton(roomId ?? 0, compact: true),
                            ],
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${room.totalRoom ?? 0}",
                        style: QuickTechAppTextStyle.bodyText4(),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${room.bookedRoom ?? 0}",
                        style: QuickTechAppTextStyle.bodyText4(),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${room.availableRoom ?? 0}",
                        style: QuickTechAppTextStyle.bodyText4(),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(
                              room.status,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: getStatusColor(
                                room.status,
                              ).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 6,
                                width: 6,
                                decoration: BoxDecoration(
                                  color: getStatusColor(room.status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                (room.status ?? "-").toUpperCase(),
                                style: QuickTechAppTextStyle.headline5()
                                    .copyWith(
                                      color: getStatusTextColor(room.status),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ACTION
                    // Mobile: shudhu delete
                    // Tablet/Desktop: ekdom right corner e delete + View Details
                    DataCell(
                      isMobile
                          ? _deleteButton(
                            roomId: roomId,
                            roomTypeId: roomTypeId,
                            propId: propId,
                            roomName: roomName,
                          )
                          : Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _deleteButton(
                                  roomId: roomId,
                                  roomTypeId: roomTypeId,
                                  propId: propId,
                                  roomName: roomName,
                                ),
                                const SizedBox(width: 8),
                                _detailsButton(roomId ?? 0),
                              ],
                            ),
                          ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _columns(bool isMobile) => [
    _col("Room Type"),
    _col("Total Room"),
    _col("Booked Room"),
    _col("Available Room"),
    _col("Status"),
    _col("Action"),
  ];

  DataColumn _col(String title) {
    return DataColumn(
      label: Text(
        title,
        style: QuickTechAppTextStyle.bodyText4().copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATES
  // ===========================================================================

  /// Mobile: simple, text responsive
  Widget _mobileEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text(
          "No room data found",
          textAlign: TextAlign.center,
          softWrap: true,
          style: QuickTechAppTextStyle.bodyText4().copyWith(color: textMuted),
        ),
      ),
    );
  }

  /// Tablet / Desktop: full width premium card
  Widget _premiumEmpty(double width) {
    final isDesktop = width >= 1024;

    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row (table er moto)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: width),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFFDD835),
                  ),
                  headingRowHeight: 56,
                  dividerThickness: 1,
                  columnSpacing: 32,
                  horizontalMargin: 24,
                  columns: _columns(false),
                  rows: const [],
                ),
              ),
            ),

            // Empty body
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 56 : 44,
                horizontal: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isDesktop ? 84 : 72,
                    height: isDesktop ? 84 : 72,
                    decoration: BoxDecoration(
                      color: mainColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: mainColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(
                      Icons.meeting_room_outlined,
                      size: isDesktop ? 40 : 34,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No rooms added yet',
                    textAlign: TextAlign.center,
                    style: QuickTechAppTextStyle.headline4().copyWith(
                      fontSize: isDesktop ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Text(
                      'This property has no rooms yet. Add your first room to start managing inventory and receiving bookings.',
                      textAlign: TextAlign.center,
                      style: QuickTechAppTextStyle.subtitle().copyWith(
                        fontSize: 13,
                        color: textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.addRoom),
                      icon: const Icon(Icons.add_home_work_rounded, size: 18),
                      label: const Text(
                        'Add Room',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ===========================================================================
  // BUTTONS
  // ===========================================================================

  Widget _deleteButton({
    required int? roomId,
    required int roomTypeId,
    required int propId,
    required String roomName,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: IconButton(
        onPressed:
            (roomId == null || roomId == 0)
                ? null
                : () {
                  showDeleteRoomDialog(
                    roomName: roomName,
                    onConfirm: () {
                      controller.deleteRoom(roomId, roomTypeId, propId);
                    },
                  );
                },
        tooltip: 'Delete Room',
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
      ),
    );
  }

  Widget _detailsButton(int roomId, {bool compact = false}) {
    final enabled = roomId > 0;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap:
            enabled
                ? () {
                  Get.toNamed(AppRoutes.roomDetails, arguments: roomId);
                }
                : null,
        child: Container(
          height: compact ? 28 : 34,
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9DB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFDD835), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_outlined,
                size: compact ? 12 : 14,
                color: const Color(0xFF715800),
              ),
              const SizedBox(width: 5),
              Text(
                "View Details",
                style: QuickTechAppTextStyle.bodyText4().copyWith(
                  fontSize: compact ? 10.5 : 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF715800),
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: compact ? 8 : 10,
                color: const Color(0xFF715800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'full':
        return Colors.red;
      case 'limited':
        return Colors.grey;
      default:
        return mainColor;
    }
  }

  Color getStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'full':
        return Colors.red.shade700;
      case 'limited':
        return Colors.grey.shade700;
      default:
        return mainColor;
    }
  }
}