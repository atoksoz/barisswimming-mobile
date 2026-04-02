import '../../config/themes/bloc_theme.dart';

class CategoryModel {
  final String name;
  final String image;
  final String uuid;

  CategoryModel({
    required this.name,
    required this.image,
    required this.uuid,
  });

  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        name: "Tatlı",
        image: BlocTheme.theme.desertSvgPath,
        uuid: "240d686d-211b-11f0-8368-f2ad253d33e7",
      ),
      CategoryModel(
        name: "Meyveler",
        image: BlocTheme.theme.fruitsSvgPath,
        uuid: "3365b4e0-6f45-11ee-86ae-005056a45414",
      ),
      CategoryModel(
        name: "Soğuk İçecekler",
        image: BlocTheme.theme.coldDrinkSvgPath,
        uuid: "a1e3be9c-629c-11ee-a0cc-005056a45414",
      ),
      CategoryModel(
        name: "Sıcak İçecekler",
        image: BlocTheme.theme.hotDrinkSvgPath,
        uuid: "a7623f63-629c-11ee-a0cc-005056a45414",
      ),
      CategoryModel(
        name: "Yiyecekler",
        image: BlocTheme.theme.cafeSvgPath,
        uuid: "ad8e184f-629c-11ee-a0cc-005056a45414",
      ),
    ];
  }
}
