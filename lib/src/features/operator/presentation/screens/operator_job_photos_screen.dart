import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/repositories/operator_local_repository.dart';
import '../../../../l10n/generated/app_localizations.dart';

class OperatorJobPhotosScreen extends StatefulWidget {
  const OperatorJobPhotosScreen({
    super.key,
    required this.repository,
    required this.jobId,
    this.initialKind = 'before',
    this.picker,
  });
  final OperatorLocalRepository repository;
  final String jobId;
  final String initialKind;
  final ImagePicker? picker;

  @override
  State<OperatorJobPhotosScreen> createState() =>
      _OperatorJobPhotosScreenState();
}

class _OperatorJobPhotosScreenState extends State<OperatorJobPhotosScreen> {
  final _defaultPicker = ImagePicker();
  ImagePicker get _picker => widget.picker ?? _defaultPicker;
  final _caption = TextEditingController();
  late String _kind = widget.initialKind;
  XFile? _file;
  Uint8List? _preview;
  bool _busy = false;
  String? _message;
  bool _error = false;
  static const _captureKey = 'operator_pending_job_photo';
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _busy = true;
      _recoverPhoto();
    }
  }

  Future<void> _recoverPhoto() async {
    try {
      final pending = await _storage.read(key: _captureKey);
      if (!mounted || pending == null) return;
      final metadata = jsonDecode(pending) as Map;
      if (metadata['job_id'] != widget.jobId ||
          metadata['operator'] != widget.repository.operatorEmail) {
        return;
      }
      final result = await _picker.retrieveLostData();
      if (!mounted) return;
      final recovered =
          result.files?.firstOrNull ??
          (metadata['path'] is String
              ? XFile(metadata['path'] as String)
              : null);
      if (recovered != null) {
        final kind = metadata['kind'];
        if (['before', 'during', 'after', 'issue', 'other'].contains(kind)) {
          _kind = kind as String;
        }
        await _selectFile(recovered);
        if (mounted) {
          setState(
            () => _message =
                'Recovered a photo. Check the job and photo type, then upload it.',
          );
        }
      } else if (result.exception != null) {
        _showError(
          'The camera could not return the previous photo. Please try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        _showError(
          'Could not recover the previous photo. You can take a new one.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rememberCapture({String? path}) async {
    try {
      await _storage.write(
        key: _captureKey,
        value: jsonEncode({
          'job_id': widget.jobId,
          'operator': widget.repository.operatorEmail,
          'kind': _kind,
          'path': ?path,
        }),
      );
    } catch (_) {
      /* The current selection can still be uploaded. */
    }
  }

  Future<void> _clearCapture() async {
    try {
      await _storage.delete(key: _captureKey);
    } catch (_) {
      /* Does not affect server upload success. */
    }
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _message = message;
        _error = true;
      });
    }
  }

  Future<void> _selectFile(XFile file) async {
    if (await file.length() > 8 * 1024 * 1024) {
      _showError('This photo exceeds 8 MB. Choose a smaller image.');
      return;
    }
    final bytes = await file.readAsBytes();
    if (mounted) {
      setState(() {
        _file = file;
        _preview = bytes;
        _message = null;
        _error = false;
      });
      await _rememberCapture(path: file.path);
    }
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _rememberCapture();
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (file != null && mounted) await _selectFile(file);
      if (file == null) await _clearCapture();
    } catch (_) {
      _showError(
        'Could not open the camera or photo library. Check permissions and try again.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _upload() async {
    final bytes = _preview;
    final file = _file;
    if (bytes == null || file == null || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final ok = await widget.repository.uploadJobPhoto(
        jobId: widget.jobId,
        bytes: bytes,
        fileName: file.name,
        kind: _kind,
        caption: _caption.text.trim(),
      );
      if (!mounted) return;
      if (ok) await _clearCapture();
      if (!mounted) return;
      setState(() {
        _error = !ok;
        _message = ok
            ? 'Photo uploaded to this job.'
            : widget.repository.lastActionError ??
                  'Photo upload failed. You can retry.';
        if (ok) {
          _preview = null;
          _file = null;
          _caption.clear();
        }
      });
    } catch (_) {
      _showError(
        'Photo upload failed. Your selected photo is still available to retry.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Job photos')),
      body: AnimatedBuilder(
        animation: widget.repository,
        builder: (context, _) {
          final job = widget.repository.maybeJobById(widget.jobId);
          if (job == null) {
            return const Center(
              child: Text('This job is no longer available.'),
            );
          }
          final strings = AppLocalizations.of(context)!;
          final canAdd = widget.repository.canAddJobPhotos(job);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${job.reference ?? job.id} - ${job.plot.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(strings.optionalJobPhotosHint),
              const SizedBox(height: 12),
              if (!canAdd) Text(strings.inspectionBeforePhotos),
              if (canAdd) ...[
                const Text(
                  'Take or select a photo, review it, then upload. JPG, PNG or WebP, up to 8 MB.',
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  key: ValueKey('photo-kind-$_kind'),
                  initialValue: _kind,
                  decoration: const InputDecoration(labelText: 'Photo type'),
                  items: [
                    for (final value in [
                      'before',
                      'during',
                      'after',
                      'issue',
                      'other',
                    ])
                      DropdownMenuItem(value: value, child: Text(value)),
                  ],
                  onChanged: _busy
                      ? null
                      : (value) => setState(() => _kind = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _caption,
                  enabled: !_busy,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Caption (optional)',
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (defaultTargetPlatform == TargetPlatform.android ||
                        defaultTargetPlatform == TargetPlatform.iOS)
                      OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take photo'),
                      ),
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose photo'),
                    ),
                  ],
                ),
                if (_preview != null) ...[
                  const SizedBox(height: 14),
                  Image.memory(
                    _preview!,
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Text(
                      'Image preview unavailable. Choose a JPG, PNG or WebP.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _busy ? null : _upload,
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(_busy ? 'Uploading...' : 'Upload photo'),
                  ),
                ],
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator(),
                  ),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _error
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
              const Divider(height: 32),
              Text(
                'Uploaded photos (${job.photos.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final photo in job.photos)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo),
                  title: Text(photo.kind),
                  subtitle: Text(
                    photo.caption?.isNotEmpty == true
                        ? photo.caption!
                        : 'Photo recorded on this job',
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
