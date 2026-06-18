// mobile_app/lib/features/claims/presentation/claim_submission_dialog.dart

import 'package:flutter/material.dart';

import '../../../core/services/api_client.dart';
import '../data/claims_api_service.dart';

class ClaimSubmissionDialog
    extends StatefulWidget {
  final int attendanceId;

  const ClaimSubmissionDialog({
    super.key,
    required this.attendanceId,
  });

  @override
  State<ClaimSubmissionDialog> createState() =>
      _ClaimSubmissionDialogState();
}

class _ClaimSubmissionDialogState
    extends State<ClaimSubmissionDialog> {
  final TextEditingController
      _reasonController =
      TextEditingController();

  final ClaimsApiService
      _claimsApiService =
      ClaimsApiService(
        ApiClient(),
      );

  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    final reason =
        _reasonController.text.trim();

    if (reason.length < 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Reason must be at least 10 characters',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _claimsApiService.createClaim(
        attendanceId:
            widget.attendanceId,
        reason: reason,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Claim submitted successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: const Text(
        'Submit Claim',
      ),
      content: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          TextField(
            controller:
                _reasonController,
            maxLines: 5,
            decoration:
                const InputDecoration(
              labelText: 'Reason',
              hintText:
                  'Explain why this attendance should be reviewed',
              border:
                  OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              _isSubmitting
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                      );
                    },
          child: const Text(
            'Cancel',
          ),
        ),
        ElevatedButton(
          onPressed:
              _isSubmitting
                  ? null
                  : _submitClaim,
          child:
              _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit Claim',
                    ),
        ),
      ],
    );
  }
}