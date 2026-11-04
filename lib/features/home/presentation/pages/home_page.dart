import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/contact/presentation/widgets/contact_section.dart';
import 'package:portfolio/features/experience/presentation/widgets/experience_section.dart';
import 'package:portfolio/features/home/presentation/widgets/hero_section.dart';
import 'package:portfolio/features/home/presentation/widgets/home_footer.dart';
import 'package:portfolio/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:portfolio/features/home/presentation/widgets/metrics_row.dart';
import 'package:portfolio/features/projects/presentation/widgets/projects_section.dart';

/// Home page. Composes sections owned by each feature; it holds no data
/// itself.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<HomeSection, GlobalKey> _sectionKeys = {
    for (final section in HomeSection.values) section: GlobalKey(),
  };

  Future<void> _scrollTo(HomeSection section) async {
    final target = _sectionKeys[section]!.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: context.reduceMotion ? Duration.zero : AppMotion.slow,
      curve: AppMotion.emphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    final gap = SizedBox(height: size.sectionSpacing);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageContainer(child: HomeNavBar(onSectionSelected: _scrollTo)),
              SizedBox(height: size.isCompact ? AppSpacing.xxl : 96),
              PageContainer(
                child: HeroSection(
                  onSeeProjects: () => _scrollTo(HomeSection.projects),
                ),
              ),
              SizedBox(height: size.isCompact ? AppSpacing.xxl : 72),
              const PageContainer(child: RevealOnScroll(child: MetricsRow())),
              const SizedBox(height: AppSpacing.xxl),
              Marquee(items: _stackItems(context)),
              gap,
              PageContainer(
                child: ProjectsSection(
                  key: _sectionKeys[HomeSection.projects],
                ),
              ),
              gap,
              PageContainer(
                child: ExperienceSection(
                  key: _sectionKeys[HomeSection.experience],
                ),
              ),
              gap,
              PageContainer(
                child: ContactSection(key: _sectionKeys[HomeSection.contact]),
              ),
              const PageContainer(child: HomeFooter()),
            ],
          ),
        ),
      ),
    );
  }
}

List<String> _stackItems(BuildContext context) => [
  for (final item in context.l10n.stackItems.split(','))
    if (item.trim().isNotEmpty) item.trim(),
];
