import 'package:flutter/material.dart';

import '../../config/themes/bloc_theme.dart';
import '../../data/model/category_model.dart';

class CategorySelector extends StatefulWidget {
  final String selectedCategoryUuid;
  final Function(String) onCategoryChanged;

  const CategorySelector({
    Key? key,
    required this.selectedCategoryUuid,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late ScrollController _scrollController;
  final categories = CategoryModel.getCategories();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // İlk render'dan sonra scroll pozisyonunu ayarla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedCategory();
    });
  }

  void scrollToSelectedCategory() {
    final selectedIndex = categories.indexWhere(
      (category) => category.uuid == widget.selectedCategoryUuid,
    );

    if (selectedIndex == -1) return;

    final double itemWidth = 110; // 100 width + 10 margin
    final double screenWidth = MediaQuery.of(context).size.width;

    // Ortalamak için offset hesapla
    final double targetOffset =
        (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  final double iconBoxHeight = 45;
  Widget buildCategory(CategoryModel category) {
    final isSelected = widget.selectedCategoryUuid == category.uuid;

    return InkWell(
      onTap: () {
        widget.onCategoryChanged(category.uuid); // Fonksiyonu tetikle
      },
      child: Container(
        width: 100,
        height: 45,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? BlocTheme.theme.default500Color : BlocTheme.theme.defaultWhiteColor,
          border: Border.all(color: BlocTheme.theme.defaultGray700Color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: BlocTheme.theme.textCaption(
              color: BlocTheme.theme.default900Color,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.offset - 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          icon: Container(
            height: iconBoxHeight,
            width: iconBoxHeight,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BlocTheme.theme.defaultWhiteColor, // İç beyaz
              border: Border.all(
                color: BlocTheme.theme.default900Color, // Yeşil çerçeve
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: BlocTheme.theme.default900Color, // Yeşil ikon
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: categories.map(buildCategory).toList(),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.offset + 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          icon: Container(
            height: iconBoxHeight,
            width: iconBoxHeight,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BlocTheme.theme.defaultWhiteColor, // İç beyaz
              border: Border.all(
                color: BlocTheme.theme.default900Color, // Yeşil çerçeve
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: BlocTheme.theme.default900Color, // Yeşil ikon
            ),
          ),
        ),
      ],
    );
  }
}
