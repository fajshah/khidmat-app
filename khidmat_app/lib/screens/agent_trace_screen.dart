import 'package:flutter/material.dart';
import '../models/user_request.dart';
import '../widgets/agent_trace_card.dart';

class AgentTraceScreen extends StatelessWidget {
  final List<AgentTrace> traces;

  const AgentTraceScreen({Key? key, required this.traces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Trace Logs'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: traces.length,
        itemBuilder: (context, index) {
          return AgentTraceCard(trace: traces[index]);
        },
      ),
    );
  }
}
