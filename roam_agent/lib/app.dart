import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/widgets.dart';
import 'domain/models.dart';
import 'features/checkout_screen.dart';
import 'features/concierge_screen.dart';
import 'features/itinerary_screen.dart';
import 'features/journey_screen.dart';
import 'features/options_screen.dart';
import 'features/trip_review_screen.dart';
import 'state/roam_controller.dart';

class RoamApp extends StatelessWidget {
  const RoamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoamController(),
      child: MaterialApp(
        title: 'RoamAgent',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _StageHost(),
      ),
    );
  }
}

class _StageHost extends StatelessWidget {
  const _StageHost();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoamController>();
    if (c.busy && c.stage == JourneyStage.searching) {
      return ScreenScaffold(
        title: c.s.appName,
        s: c.s,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return switch (c.stage) {
      JourneyStage.input => const ConciergeScreen(),
      JourneyStage.clarification || JourneyStage.validated => const TripReviewScreen(),
      JourneyStage.searching => const OptionsScreen(),
      JourneyStage.optionsReady => const OptionsScreen(),
      JourneyStage.itinerarySelected => const ItineraryScreen(),
      JourneyStage.demoConfirmation || JourneyStage.demoChangeConfirmation => const CheckoutScreen(),
      JourneyStage.active ||
      JourneyStage.disrupted ||
      JourneyStage.completed =>
        const JourneyScreen(),
      JourneyStage.recoveryPending ||
      JourneyStage.proposalReady ||
      JourneyStage.awaitingApproval =>
        const RecoveryScreen(),
      JourneyStage.cancelled => const ConciergeScreen(),
    };
  }
}
