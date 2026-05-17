import 'package:flutter/material.dart';
import '../models/user_request.dart';
import 'dart:convert';

class AgentTraceCard extends StatelessWidget {
  final AgentTrace trace;

  const AgentTraceCard({Key? key, required this.trace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor = trace.status == 'done' ? Colors.green : Colors.orange;
    IconData statusIcon = trace.status == 'done' ? Icons.check_circle : Icons.sync;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          trace.agent,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Step ${trace.step} - ${trace.status.toUpperCase()}'),
        children: [
          if (trace.output != null)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.grey.withOpacity(0.05),
              child: SelectableText(
                _formatOutput(trace.output),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  String _formatOutput(dynamic output) {
    try {
      if (output is Map || output is List) {
        return const JsonEncoder.withIndent('  ').convert(output);
      }
      return output.toString();
    } catch (e) {
      return output.toString();
    }
  }
}
