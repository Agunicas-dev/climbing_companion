import 'package:climbing_companion/components/charts/line_chart.dart';
import 'package:climbing_companion/components/charts/pie_chart.dart';
import 'package:climbing_companion/components/profile_card.dart';
import 'package:climbing_companion/components/statistics/global_statistics_summary.dart';
import 'package:climbing_companion/screens/settings_screen.dart';
import 'package:climbing_companion/services/grade_scale_service.dart';
import 'package:climbing_companion/services/settings_service.dart';
import 'package:climbing_companion/services/statistics_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = 'Climber';
  String _profilePicturePath = '';
  bool _likesBouldering = true;
  bool _likesLead = true;
  String _gradingSystem = 'hueco';
  bool _loading = true;
  int _sessionTimeRange = 5;
  late Future<GlobalClimbingStatistics> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _statisticsFuture = StatisticsService.getGlobalStatistics();
  }

  Future<void> _loadUserData() async {
    final s = await SettingsService.loadSettings();
    if (mounted) {
      setState(() {
        _username = s.username.isNotEmpty ? s.username : 'Climber';
        _profilePicturePath = s.profilePicturePath;
        _likesBouldering = s.likesBouldering;
        _likesLead = s.likesLead;
        _gradingSystem = s.gradingSystem;
        _loading = false;
      });
    }
  }

  void _refreshStatistics() {
    setState(() {
      _statisticsFuture = StatisticsService.getGlobalStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        shadowColor: Colors.black,
        elevation: 3,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SettingsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    //Difining the constants for the navigation animation.
                    //Doing it with constants to make the code more readable and easier to change if needed.
                    //Don't know if this is the best way to do it, had to rely on ai and online forum posts for this one a bit.
                    const begin = Offset.zero;
                    const end = Offset(-1.0, 0.0);
                    const curve = Curves.easeOutSine;
                    const secondaryBegin = Offset(1.0, 0.0);
                    const secondaryEnd = Offset.zero;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    var secondaryTween = Tween(
                      begin: secondaryBegin,
                      end: secondaryEnd,
                    ).chain(CurveTween(curve: curve));
                    var secondaryOffsetAnimation = secondaryAnimation.drive(
                      secondaryTween,
                    );

                    return SlideTransition(
                      position: offsetAnimation,
                      child: SlideTransition(
                        position: secondaryOffsetAnimation,
                        child: child,
                      ),
                    );
                  },
                ),
              ).then((_) {
                _loadUserData();
                _refreshStatistics();
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ProfileCard(
            username: _loading ? 'Loading...' : _username,
            profilePicturePath: _profilePicturePath,
            doesBouldering: _likesBouldering,
            doesLead: _likesLead,
          ),
          const SizedBox(height: 12),
          FutureBuilder<GlobalClimbingStatistics>(
            future: _statisticsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Could not load statistics',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              final statistics = snapshot.data;
              if (statistics == null || statistics.sessionCount == 0) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No statistics yet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              return Column(
                children: [
                  GlobalStatisticsSummary(statistics: statistics),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sessions',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            DropdownButton<int>(
                              value: _sessionTimeRange,
                              items: const [
                                DropdownMenuItem(value: 3, child: Text('3m')),
                                DropdownMenuItem(value: 5, child: Text('5m')),
                                DropdownMenuItem(value: 12, child: Text('12m')),
                                DropdownMenuItem(value: 0, child: Text('Max')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _sessionTimeRange = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        ClimbingLineChart(
                          data: statistics.sessionsLastNMonths(_sessionTimeRange),
                          title: '', // Title handled by Row above
                          valueLabel: 'Sessions',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClimbingLineChart(
                      data: statistics.maxGradeTimeline,
                      title: 'Max Grade Progression',
                      valueLabel: 'Grade',
                      color: Colors.orange,
                      yLabels: GradeScaleService.gradesForSystem(_gradingSystem),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClimbingPieChart(
                      data: statistics.successDistribution,
                      title: 'Success Distribution',
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
