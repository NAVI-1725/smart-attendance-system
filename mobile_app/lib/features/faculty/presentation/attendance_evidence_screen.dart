// mobile_app/lib/features/faculty/presentation/attendance_evidence_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance_evidence.dart';
import '../presentation/faculty_provider.dart';

class AttendanceEvidenceScreen
    extends ConsumerStatefulWidget {
  final int attendanceId;

  const AttendanceEvidenceScreen({
    super.key,
    required this.attendanceId,
  });

  @override
  ConsumerState<AttendanceEvidenceScreen>
      createState() =>
          _AttendanceEvidenceScreenState();
}

class _AttendanceEvidenceScreenState
    extends ConsumerState<AttendanceEvidenceScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref
            .read(facultyProvider)
            .loadAttendanceEvidence(
              widget.attendanceId,
            );
      },
    );
  }

  String _extractField(
    Map<String, dynamic>? data,
    String key,
  ) {
    if (data == null) {
      return 'N/A';
    }

    final value = data[key];

    if (value == null) {
      return 'N/A';
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Evidence',
        ),
      ),
      body: Consumer(
        builder: (
          context,
          ref,
          _,
        ) {
          final provider = ref.watch(
            facultyProvider,
          );

          if (provider.isLoading &&
              provider.attendanceEvidence ==
                  null) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final evidence =
              provider.attendanceEvidence;

          if (evidence == null) {
            return const Center(
              child: Text(
                'No evidence available',
              ),
            );
          }

          return ListView(
            padding:
                const EdgeInsets.all(16),
            children: [
              const Text(
                'BLE Evidence',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...evidence.ble.map(
                (ble) =>
                    _BleEvidenceCard(
                  evidence: ble,
                  extractField:
                      _extractField,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'GPS Evidence',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (evidence.gps != null)
                _GpsEvidenceCard(
                  gps: evidence.gps!,
                )
              else
                const Card(
                  child: Padding(
                    padding:
                        EdgeInsets.all(16),
                    child: Text(
                      'No GPS evidence available',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BleEvidenceCard extends StatelessWidget {
  final BleEvidence evidence;

  final String Function(
    Map<String, dynamic>?,
    String,
  ) extractField;

  const _BleEvidenceCard({
    required this.evidence,
    required this.extractField,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? beaconPayload =
        evidence.beaconData?['per_beacon']
            as Map<String, dynamic>?;

    final String overallProximity =
        evidence.beaconData?['overall']
                ?.toString() ??
            'N/A';

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _EvidenceRow(
              label:
                  'Overall Proximity',
              value:
                  overallProximity,
            ),
            const SizedBox(height: 12),
            if (beaconPayload == null ||
                beaconPayload.isEmpty)
              const Text(
                'No beacon evidence available',
              )
            else
              ...beaconPayload.entries
                  .expand(
                (entry) {
                  final beaconData =
                      entry.value
                              as Map<
                                  String,
                                  dynamic>? ??
                          {};

                  return [
                    Text(
                      entry.key,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    _EvidenceRow(
                      label:
                          'Beacon Name',
                      value:
                          entry.key,
                    ),
                    _EvidenceRow(
                      label:
                          'RSSI',
                      value:
                          beaconData[
                                      'average_rssi']
                                  ?.toString() ??
                              'N/A',
                    ),
                    _EvidenceRow(
                      label:
                          'Sample Count',
                      value:
                          beaconData[
                                      'sample_count']
                                  ?.toString() ??
                              'N/A',
                    ),
                    _EvidenceRow(
                      label:
                          'Nonce',
                      value:
                          beaconData[
                                      'nonce']
                                  ?.toString() ??
                              'N/A',
                    ),
                    _EvidenceRow(
                      label:
                          'Signature',
                      value:
                          beaconData[
                                      'signature']
                                  ?.toString() ??
                              'N/A',
                    ),
                    _EvidenceRow(
                      label:
                          'Proximity',
                      value:
                          beaconData[
                                      'proximity']
                                  ?.toString() ??
                              'N/A',
                    ),
                    const Divider(
                      height: 24,
                    ),
                  ];
                },
              ),
            _EvidenceRow(
              label:
                  'Client Timestamp',
              value:
                  evidence.clientTimestamp ??
                  'N/A',
            ),
            _EvidenceRow(
              label:
                  'Server Received Timestamp',
              value:
                  evidence
                      .serverReceivedTimestamp ??
                  'N/A',
            ),
          ],
        ),
      ),
    );
  }
}

class _GpsEvidenceCard extends StatelessWidget {
  final GpsEvidence gps;

  const _GpsEvidenceCard({
    required this.gps,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _EvidenceRow(
              label: 'Latitude',
              value:
                  gps.latitude.toString(),
            ),
            _EvidenceRow(
              label: 'Longitude',
              value:
                  gps.longitude.toString(),
            ),
            _EvidenceRow(
              label: 'Accuracy',
              value:
                  gps.accuracyMeters
                      .toString(),
            ),
            _EvidenceRow(
              label: 'Distance',
              value: gps
                      .distanceFromClassroomMeters
                      ?.toString() ??
                  'N/A',
            ),
            _EvidenceRow(
              label:
                  'Validation Result',
              value:
                  gps.validationResult ??
                  'N/A',
            ),
            _EvidenceRow(
              label:
                  'Validation Reason',
              value:
                  gps.validationReason ??
                  'N/A',
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  final String label;
  final String value;

  const _EvidenceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}