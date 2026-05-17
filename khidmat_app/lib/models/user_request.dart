import 'provider.dart';

class AgentTrace {
  final int step;
  final String agent;
  final String status;
  final dynamic output;

  AgentTrace({
    required this.step,
    required this.agent,
    required this.status,
    this.output,
  });

  factory AgentTrace.fromJson(Map<String, dynamic> json) {
    return AgentTrace(
      step: json['step'] ?? 0,
      agent: json['agent'] ?? '',
      status: json['status'] ?? '',
      output: json['output'],
    );
  }
}

class RequestResponse {
  final bool success;
  final String userInput;
  final Map<String, dynamic> intent;
  final List<Provider> providers;
  final Provider? recommended;
  final List<AgentTrace> agentTrace;
  final String? error;
  final String reasoning;

  RequestResponse({
    required this.success,
    required this.userInput,
    required this.intent,
    required this.providers,
    this.recommended,
    required this.agentTrace,
    this.error,
    this.reasoning = '',
  });

  factory RequestResponse.fromJson(Map<String, dynamic> json) {
    var traceList = json['agent_trace'] as List? ?? [];
    List<AgentTrace> traces = traceList.map((e) => AgentTrace.fromJson(e)).toList();
    
    List<Provider> providersList = [];
    if (json['providers'] != null) {
      providersList = (json['providers'] as List).map((e) {
        var p = Provider.fromJson(e);
        // find score in all_ranked if present
        double score = 0.0;
        if (json['all_ranked'] != null) {
          try {
            var rankedMatch = (json['all_ranked'] as List).firstWhere((r) => r['name'] == p.name, orElse: () => null);
            if (rankedMatch != null) {
               score = (rankedMatch['score'] ?? 0.0).toDouble();
            }
          } catch(e) {}
        }
        return Provider(
          id: p.id,
          name: p.name,
          service: p.service,
          available: p.available,
          area: p.area,
          rating: p.rating,
          distanceKm: p.distanceKm,
          score: score,
        );
      }).toList();
    }

    Provider? rec;
    if (json['recommended'] != null && json['recommended'] is Map) {
      rec = Provider.fromJson(json['recommended'] as Map<String, dynamic>);
      try {
        rec = providersList.firstWhere((p) => p.name == rec!.name);
      } catch(e) {}
    }

    return RequestResponse(
      success: json['success'] ?? false,
      userInput: json['user_input'] ?? '',
      intent: json['intent'] ?? {},
      providers: providersList,
      recommended: rec,
      agentTrace: traces,
      error: json['error'],
      reasoning: json['reasoning'] ?? '',
    );
  }
}
