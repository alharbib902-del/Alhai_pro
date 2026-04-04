/// حقل إدخال المحادثة - AI Chat Input
///
/// حقل نص مع زر إرسال وأيقونة ميكروفون
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// حقل إدخال المحادثة
class AiChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isProcessing;

  const AiChatInput({
    super.key,
    required this.onSend,
    this.isProcessing = false,
  });

  @override
  State<AiChatInput> createState() => _AiChatInputState();
}

class _AiChatInputState extends State<AiChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isProcessing) return;

    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
          AlhaiSpacing.md, AlhaiSpacing.xs, AlhaiSpacing.md, AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر الميكروفون (معطل حالياً)
            _buildMicButton(isDark),
            const SizedBox(width: AlhaiSpacing.xs),

            // حقل النص
            Expanded(child: _buildTextField(isDark)),
            const SizedBox(width: AlhaiSpacing.xs),

            // زر الإرسال
            _buildSendButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton(bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.mic_rounded,
        color: isDark ? Colors.white24 : AppColors.grey400,
        size: 20,
      ),
    );
  }

  Widget _buildTextField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.grey50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textDirection: Directionality.of(context),
        maxLines: 3,
        minLines: 1,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _sendMessage(),
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'اكتب سؤالك هنا...', // Type your question here...
          hintStyle: TextStyle(
            color: isDark ? Colors.white30 : AppColors.textMuted,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md,
            vertical: 10,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSendButton(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient:
            _hasText && !widget.isProcessing ? AppColors.primaryGradient : null,
        color: _hasText && !widget.isProcessing
            ? null
            : isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.grey200,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _hasText && !widget.isProcessing
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _hasText && !widget.isProcessing ? _sendMessage : null,
          borderRadius: BorderRadius.circular(14),
          child: widget.isProcessing
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  color: _hasText
                      ? Colors.white
                      : isDark
                          ? Colors.white24
                          : AppColors.grey400,
                  size: 20,
                ),
        ),
      ),
    );
  }
}
