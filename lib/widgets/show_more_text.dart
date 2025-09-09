import 'package:flutter/material.dart';

class ShowMoreText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final double? showMoreSize;

  const ShowMoreText(
    this.text, {
    super.key,
    this.maxLines = 2,
    this.style,
    this.textAlign,
    this.textDirection,
    this.showMoreSize,
  });

  @override
  State<ShowMoreText> createState() => _ShowMoreTextState();
}

class _ShowMoreTextState extends State<ShowMoreText> {
  bool _showMore = false;
  bool _isTextOverflowing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkTextOverflow();
  }

  void _checkTextOverflow() {
    final textHeight = _getTextHeight();
    final containerHeight = _getContainerHeight();

    setState(() {
      _isTextOverflowing = textHeight > containerHeight;
    });
  }

  double _getTextHeight() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: widget.textDirection ?? TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width);
    return textPainter.size.height;
  }

  double _getContainerHeight() {
    return widget.maxLines * (widget.style?.fontSize ?? 14) * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _showMore ? null : widget.maxLines,
          style: widget.style,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          overflow: _showMore ? null : TextOverflow.ellipsis,
        ),
        if (_isTextOverflowing)
          TextButton(
            onPressed: () {
              setState(() {
                _showMore = !_showMore;
              });
            },
            child: Text(
              _showMore ? "less" : "more",
              style: TextStyle(fontSize: widget.showMoreSize ?? 14),
            ),
          ),
      ],
    );
  }
}
