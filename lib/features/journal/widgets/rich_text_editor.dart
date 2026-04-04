import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../core/theme/app_colors.dart';

/// Rich text editor widget for journal entries using Quill
class RichTextJournalEditor extends StatefulWidget {
  final String? initialContent;
  final String? initialDelta;
  final String? placeholder;
  final bool readOnly;
  final bool autoFocus;
  final ValueChanged<String>? onContentChanged;
  final ValueChanged<String>? onDeltaChanged;
  final FocusNode? focusNode;

  const RichTextJournalEditor({
    super.key,
    this.initialContent,
    this.initialDelta,
    this.placeholder,
    this.readOnly = false,
    this.autoFocus = true,
    this.onContentChanged,
    this.onDeltaChanged,
    this.focusNode,
  });

  @override
  State<RichTextJournalEditor> createState() => RichTextJournalEditorState();
}

class RichTextJournalEditorState extends State<RichTextJournalEditor> {
  late QuillController _controller;
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _scrollController = ScrollController();
    _initializeController();
  }

  void _initializeController() {
    Document document;
    
    if (widget.initialDelta != null && widget.initialDelta!.isNotEmpty) {
      try {
        final delta = jsonDecode(widget.initialDelta!) as List<dynamic>;
        document = Document.fromJson(delta);
      } catch (e) {
        document = Document()..insert(0, widget.initialContent ?? '');
      }
    } else if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      document = Document()..insert(0, widget.initialContent!);
    } else {
      document = Document();
    }
    
    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    _controller.addListener(_onDocumentChanged);
  }

  void _onDocumentChanged() {
    final plainText = _controller.document.toPlainText().trim();
    widget.onContentChanged?.call(plainText);
    
    final delta = jsonEncode(_controller.document.toDelta().toJson());
    widget.onDeltaChanged?.call(delta);
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocumentChanged);
    _controller.dispose();
    _scrollController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  /// Get plain text content
  String getPlainText() {
    return _controller.document.toPlainText().trim();
  }

  /// Get delta JSON for storage
  String getDeltaJson() {
    return jsonEncode(_controller.document.toDelta().toJson());
  }

  /// Get word count
  int getWordCount() {
    final text = getPlainText();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  /// Check if editor has content
  bool hasContent() {
    return getPlainText().isNotEmpty;
  }

  /// Clear the editor
  void clear() {
    _controller.clear();
  }

  /// Set content from plain text
  void setPlainText(String text) {
    _controller.document = Document()..insert(0, text);
  }

  /// Set content from delta JSON
  void setDelta(String deltaJson) {
    try {
      final delta = jsonDecode(deltaJson) as List<dynamic>;
      _controller.document = Document.fromJson(delta);
    } catch (e) {
      debugPrint('Error parsing delta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        // Toolbar (only show if not read-only)
        if (!widget.readOnly) _buildToolbar(theme, isDark),
        
        // Editor
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.surfaceDark 
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: QuillEditor.basic(
                controller: _controller,
                focusNode: _focusNode,
                scrollController: _scrollController,
                config: QuillEditorConfig(
                  autoFocus: widget.autoFocus,
                  expands: true,
                  padding: const EdgeInsets.all(16),
                  placeholder: widget.placeholder ?? 'Start writing...',
                  customStyles: _getCustomStyles(theme, isDark),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.surfaceDark 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: QuillSimpleToolbar(
        controller: _controller,
        config: QuillSimpleToolbarConfig(
          showAlignmentButtons: false,
          showBackgroundColorButton: false,
          showCenterAlignment: false,
          showClearFormat: true,
          showCodeBlock: false,
          showColorButton: false,
          showDividers: true,
          showFontFamily: false,
          showFontSize: false,
          showHeaderStyle: true,
          showIndent: false,
          showInlineCode: false,
          showJustifyAlignment: false,
          showLeftAlignment: false,
          showLink: false,
          showListBullets: true,
          showListCheck: true,
          showListNumbers: true,
          showQuote: true,
          showRightAlignment: false,
          showSearchButton: false,
          showStrikeThrough: true,
          showSubscript: false,
          showSuperscript: false,
          showUnderLineButton: true,
          toolbarIconAlignment: WrapAlignment.start,
          toolbarSectionSpacing: 4,
          multiRowsDisplay: false,
          buttonOptions: QuillSimpleToolbarButtonOptions(
            base: QuillToolbarBaseButtonOptions(
              iconTheme: QuillIconTheme(
                iconButtonSelectedData: IconButtonData(
                  color: AppColors.primary,
                ),
                iconButtonUnselectedData: IconButtonData(
                  color: isDark 
                      ? AppColors.textPrimaryDark 
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DefaultStyles _getCustomStyles(ThemeData theme, bool isDark) {
    final baseStyle = TextStyle(
      fontSize: 16,
      height: 1.6,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
    
    return DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        baseStyle,
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(8, 8),
        const VerticalSpacing(0, 0),
        null,
      ),
      h1: DefaultTextBlockStyle(
        baseStyle.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(16, 8),
        const VerticalSpacing(0, 0),
        null,
      ),
      h2: DefaultTextBlockStyle(
        baseStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(12, 6),
        const VerticalSpacing(0, 0),
        null,
      ),
      h3: DefaultTextBlockStyle(
        baseStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(8, 4),
        const VerticalSpacing(0, 0),
        null,
      ),
      bold: const TextStyle(fontWeight: FontWeight.bold),
      italic: const TextStyle(fontStyle: FontStyle.italic),
      underline: const TextStyle(decoration: TextDecoration.underline),
      strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
      placeHolder: DefaultTextBlockStyle(
        baseStyle.copyWith(
          color: isDark 
              ? AppColors.textSecondaryDark 
              : AppColors.textSecondaryLight,
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(8, 8),
        const VerticalSpacing(0, 0),
        null,
      ),
      lists: DefaultListBlockStyle(
        baseStyle,
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(8, 8),
        const VerticalSpacing(0, 0),
        null,
        null,
      ),
      quote: DefaultTextBlockStyle(
        baseStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: isDark 
              ? AppColors.textSecondaryDark 
              : AppColors.textSecondaryLight,
        ),
        const HorizontalSpacing(16, 0),
        const VerticalSpacing(8, 8),
        const VerticalSpacing(0, 0),
        BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.primary.withOpacity(0.5),
              width: 4,
            ),
          ),
        ),
      ),
    );
  }
}

/// Read-only rich text viewer for displaying journal entries
class RichTextViewer extends StatelessWidget {
  final String? content;
  final String? deltaJson;

  const RichTextViewer({
    super.key,
    this.content,
    this.deltaJson,
  });

  @override
  Widget build(BuildContext context) {
    Document document;
    
    if (deltaJson != null && deltaJson!.isNotEmpty) {
      try {
        final delta = jsonDecode(deltaJson!) as List<dynamic>;
        document = Document.fromJson(delta);
      } catch (e) {
        document = Document()..insert(0, content ?? '');
      }
    } else if (content != null && content!.isNotEmpty) {
      document = Document()..insert(0, content!);
    } else {
      document = Document();
    }
    
    final controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return QuillEditor.basic(
      controller: controller,
      focusNode: FocusNode(),
      scrollController: ScrollController(),
      config: QuillEditorConfig(
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        customStyles: _getViewerStyles(theme, isDark),
      ),
    );
  }

  DefaultStyles _getViewerStyles(ThemeData theme, bool isDark) {
    final baseStyle = TextStyle(
      fontSize: 16,
      height: 1.6,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
    
    return DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        baseStyle,
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(4, 4),
        const VerticalSpacing(0, 0),
        null,
      ),
      h1: DefaultTextBlockStyle(
        baseStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(12, 6),
        const VerticalSpacing(0, 0),
        null,
      ),
      h2: DefaultTextBlockStyle(
        baseStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(8, 4),
        const VerticalSpacing(0, 0),
        null,
      ),
      bold: const TextStyle(fontWeight: FontWeight.bold),
      italic: const TextStyle(fontStyle: FontStyle.italic),
      underline: const TextStyle(decoration: TextDecoration.underline),
      strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
      quote: DefaultTextBlockStyle(
        baseStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: isDark 
              ? AppColors.textSecondaryDark 
              : AppColors.textSecondaryLight,
        ),
        const HorizontalSpacing(12, 0),
        const VerticalSpacing(4, 4),
        const VerticalSpacing(0, 0),
        BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.primary.withOpacity(0.5),
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}
