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
        return const Center(child: CircularProgressIndicator());
      }

      final rooms = controller.roomList.value.propertyRoomRecords ?? [];

      if (rooms.isEmpty) {
        return const Center(child: Text("No room data found"));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerTheme: const DividerThemeData(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFFDD835),
                    ),
                    dividerThickness: 1,
                    dataRowColor: WidgetStateProperty.all(Colors.white),
                    columnSpacing: 20,
                    horizontalMargin: 12,
                    columns: [
                      _col("Room Type"),
                      _col("Total Room"),
                      _col("Booked Room"),
                      _col("Available Room"),
                      _col("Status"),
                      _col("Action"),
                    ],
                    rows:
                        rooms.map((room) {
                   final int? roomId = room.propertyRoom?.id ?? room.id;
final int roomTypeId = room.roomTypeId ?? room.roomType?.id ?? 0;
final int propId = room.propertyId ?? _effectivePropertyId;
final String roomName =
    room.propertyRoom?.roomName ?? room.roomType?.name ?? 'this room';

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  room.roomType?.name ?? "-",
                                  style: QuickTechAppTextStyle.bodyText4(),
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
                                          style:
                                              QuickTechAppTextStyle.headline5()
                                                  .copyWith(
                                                    color: getStatusTextColor(
                                                      room.status,
                                                    ),
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                  ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
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
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

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

Widget _detailsButton(int roomId) {
  return OutlinedButton.icon(
    onPressed:
        roomId > 0
            ? () {
              Get.toNamed(AppRoutes.roomDetails, arguments: roomId);
            }
            : null,
    icon: const Icon(Icons.visibility_outlined, size: 16),
    label: Text(
      'Details',
      style: QuickTechAppTextStyle.bodyText4().copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black87,
      side: BorderSide(color: mainColor, width: 1.4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
