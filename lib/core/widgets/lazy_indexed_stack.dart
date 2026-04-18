import 'package:flutter/material.dart';

/// [IndexedStack] ile aynı görünür davranış: yalnızca [index] ekranda; fakat
/// henüz seçilmemiş sekmeler için child oluşturulmaz ([StatefulWidget.initState]
/// çalışmaz). Bir kez açılan sekme [tabEverBuilt] ile işaretlenir ve geri dönünce
/// durumu korunur ([Offstage]).
///
/// Arka planda (ör. QR ekranı) istek / diyalog tetiklenmesini önlemek için kullanılır.
class LazyIndexedStack extends StatelessWidget {
  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.tabEverBuilt,
    required this.children,
  });

  final int index;
  final List<bool> tabEverBuilt;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(
      tabEverBuilt.length == children.length,
      'tabEverBuilt (${tabEverBuilt.length}) must match children (${children.length})',
    );
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: List<Widget>.generate(children.length, (i) {
        if (!tabEverBuilt[i]) {
          return const SizedBox.shrink();
        }
        return Positioned.fill(
          child: Offstage(
            offstage: i != index,
            child: TickerMode(
              enabled: i == index,
              child: children[i],
            ),
          ),
        );
      }),
    );
  }
}
