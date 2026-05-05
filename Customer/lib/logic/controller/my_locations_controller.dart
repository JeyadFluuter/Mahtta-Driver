import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:biadgo/models/new_location_model.dart';
import 'package:biadgo/services/locations_services.dart';

class MyLocationsController extends GetxController {
  static const int _perPage = 15;
  final _service = LocationsServices();
  final RxBool isLoading = false.obs;

  int? _totalPages;

  late final PagingController<int, DataLocation> pagingController =
      PagingController<int, DataLocation>(
    getNextPageKey: (state) {
      final next = (state.keys?.last ?? 0) + 1;
      if (_totalPages != null && next > _totalPages!) return null;
      return next;
    },
    fetchPage: (pageKey) async {
      final page = pageKey;
      final (items, totalPages) =
          await _service.fetchPage(page: page, perPage: _perPage);

      _totalPages = totalPages;
      return items;
    },
  );

  final dropdownLocations = RxList<DataLocation>();

  @override
  void onInit() {
    super.onInit();
    pagingController.refresh();
    loadAllForDropdown();
  }

  Future<void> loadAllForDropdown() async {
    try {
      final all = <DataLocation>[];
      int p = 1;
      while (true) {
        final (items, total) =
            await _service.fetchPage(page: p, perPage: _perPage);
        all.addAll(items);
        if (p >= total) break;
        p++;
      }
      dropdownLocations.assignAll(all);
    } catch (e) {
      debugPrint('⚠️  Dropdown load error: $e');
    }
  }

  Future<void> refreshData() async {
    pagingController.refresh();
    return;
  }
}
