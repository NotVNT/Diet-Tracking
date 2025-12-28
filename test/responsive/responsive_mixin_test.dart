import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/responsive/responsive_mixin.dart';

class _MixinProbe extends StatefulWidget {
  final void Function(_MixinProbeState state) onBuilt;
  const _MixinProbe({required this.onBuilt});

  @override
  State<_MixinProbe> createState() => _MixinProbeState();
}

class _MixinProbeState extends State<_MixinProbe> with ResponsiveMixin<_MixinProbe> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onBuilt(this);
    });
    return const SizedBox.shrink();
  }
}

void main() {
  Future<void> withSize(WidgetTester tester, Size size, void Function(_MixinProbeState) verify) async {
    _MixinProbeState? captured;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          home: _MixinProbe(
            onBuilt: (s) => captured = s,
          ),
        ),
      ),
    );
    await tester.pump();
    verify(captured!);
  }

  group('ResponsiveMixin basics', () {
    testWidgets('helpers return sensible values', (tester) async {
      await withSize(tester, const Size(390, 844), (st) {
        expect(st.rWidth(100) > 0, true);
        expect(st.rHeight(50) > 0, true);
        expect(st.rDimension(10) > 0, true);
        expect(st.rFontSize(16) > 0, true);
        expect(st.rIconSize(20) > 0, true);
        expect(st.rSpacing(8) > 0, true);
        expect(st.rRadius(12) > 0, true);

        final pad = st.rPadding(horizontal: 16, vertical: 12);
        expect(pad.left > 0, true);
        expect(pad.top > 0, true);

        final styled = st.rTextStyle(const TextStyle(fontSize: 14));
        expect(styled.fontSize, isNotNull);
      });
    });

    testWidgets('device type flags are consistent', (tester) async {
      // Small phone
      await withSize(tester, const Size(350, 700), (st) {
        expect(st.isSmallPhone, true);
        expect(st.isPhone, false);
        expect(st.isTablet, false);
      });
      // Phone
      await withSize(tester, const Size(380, 700), (st) {
        expect(st.isSmallPhone, false);
        expect(st.isPhone, true);
        expect(st.isTablet, false);
      });
      // Tablet
      await withSize(tester, const Size(1000, 1200), (st) {
        expect(st.isTablet, true);
      });
    });

    testWidgets('safe area getters are available', (tester) async {
      await withSize(tester, const Size(390, 844), (st) {
        expect(st.topSafeArea, isA<double>());
        expect(st.bottomSafeArea, isA<double>());
      });
    });
  });
}

