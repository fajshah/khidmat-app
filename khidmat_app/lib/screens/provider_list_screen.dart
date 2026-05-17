import 'package:flutter/material.dart';
import '../models/user_request.dart';
import '../widgets/provider_card.dart';
import '../services/api_service.dart';
import 'booking_screen.dart';
import 'agent_trace_screen.dart';

class ProviderListScreen extends StatefulWidget {
  final RequestResponse response;

  const ProviderListScreen({Key? key, required this.response}) : super(key: key);

  @override
  _ProviderListScreenState createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final ApiService _apiService = ApiService();
  bool _isBooking = false;

  void _bookProvider(String providerId, String providerName, String slot) async {
    setState(() {
      _isBooking = true;
    });

    try {
      final booking = await _apiService.createBooking(
        providerId: providerId,
        providerName: providerName,
        service: widget.response.intent['service_type'] ?? 'Service',
        slot: slot,
        userName: 'Test User', // Hardcoded for demo
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(
            booking: booking,
            trace: widget.response.agentTrace,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommended = widget.response.recommended;
    final allProviders = widget.response.providers;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: _isBooking
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Confirming your booking...',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Available Providers',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.psychology_outlined, color: Colors.white),
                      tooltip: 'View Agent Trace',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgentTraceScreen(traces: widget.response.agentTrace),
                          ),
                        );
                      },
                    )
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (recommended != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            'Best Match for You',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        ProviderCard(
                          provider: recommended,
                          isRecommended: true,
                          onBook: (slot) => _bookProvider(recommended.id, recommended.name, slot),
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Divider(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'Other Options',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      ...allProviders
                          .where((p) => p.id != recommended?.id)
                          .map((p) => ProviderCard(
                                provider: p,
                                isRecommended: false,
                                onBook: (slot) => _bookProvider(p.id, p.name, slot),
                              ))
                          .toList(),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}
