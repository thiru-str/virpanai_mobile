import 'package:flutter/material.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

enum TutorialPhase { home, categories, product, cart, wishlist }

class TutorialCoordinator {
  static final TutorialCoordinator _i = TutorialCoordinator._();
  factory TutorialCoordinator() => _i;
  TutorialCoordinator._();

  bool isActive = false;
  TutorialPhase _phase = TutorialPhase.home;
  TutorialPhase get phase => _phase;

  static const _prefKey = 'tutorial_seen_v1';

  Future<bool> shouldShow() async {
    final seen = await SharedPreferencesUtil().getBool(_prefKey);
    return seen != true;
  }

  void start() {
    isActive = true;
    _phase = TutorialPhase.home;
  }

  void advanceTo(TutorialPhase next) {
    _phase = next;
  }

  Future<void> complete() async {
    isActive = false;
    await SharedPreferencesUtil().saveBool(_prefKey, true);
  }

  Future<void> reset() async {
    await SharedPreferencesUtil().saveBool(_prefKey, false);
  }
}

mixin TutorialMixin<T extends StatefulWidget> on State<T> {
  TutorialPhase? _scheduledPhase;

  void maybeStartTutorial(
    TutorialPhase phase,
    VoidCallback show, {
    Duration delay = const Duration(milliseconds: 400),
  }) {
    if (_scheduledPhase == phase) return;
    if (!TutorialCoordinator().isActive) return;
    if (TutorialCoordinator().phase != phase) return;
    _scheduledPhase = phase;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future.delayed(delay);
      if (!mounted) return;
      show();
    });
  }
}
