import 'package:get/get.dart';
import '../models/unfurnised_model.dart';
import '../api/api_unfurnished_flat.dart';

class UnfurnishedController extends GetxController {
  var isLoading = true.obs;
  var unfurnishedFlats = <UnfurnishedFlat>[].obs;

  @override
  void onInit() {
    fetchUnfurnishedFlats();
    super.onInit();
  }

  void fetchUnfurnishedFlats() async {
    try {
      isLoading(true);
      final flats = await ApiUnfurnishedFlat.getUnfurnishedFlats();
      unfurnishedFlats.assignAll(flats);
    } finally {
      isLoading(false);
    }
  }
}
