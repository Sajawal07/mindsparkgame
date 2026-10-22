import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AnswerOptionsWidget extends StatefulWidget {
  const AnswerOptionsWidget({
    super.key,
    required this.options,
    required this.correctAnswer,
    required this.onAnswerSelected,
    this.childAspectRatio = 2.5,
    this.maxOptionLines = 2,
  });

  final List<String> options;
  final String correctAnswer;
  final Function(String) onAnswerSelected;
  final double childAspectRatio;
  final int maxOptionLines;

  @override
  State<AnswerOptionsWidget> createState() => _AnswerOptionsWidgetState();
}

class _AnswerOptionsWidgetState extends State<AnswerOptionsWidget>
    with TickerProviderStateMixin {
  String? _selectedAnswer;
  bool _isAnswered = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 1),
    ]).animate(_shakeController);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(_bounceController);
  }

  @override
  void didUpdateWidget(AnswerOptionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      setState(() {
        _selectedAnswer = null;
        _isAnswered = false;
      });
      _shakeController.reset();
      _bounceController.reset();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleSelect(String option) {
    if (_isAnswered) return;
    setState(() {
      _selectedAnswer = option;
      _isAnswered = true;
    });

    if (option == widget.correctAnswer) {
      _bounceController.forward();
    } else {
      _shakeController.forward();
    }

    widget.onAnswerSelected(option);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: widget.childAspectRatio,
      children: widget.options.map((option) {
        final isSelected = option == _selectedAnswer;
        final isCorrect = option == widget.correctAnswer;
        
        Color buttonColor = AppColors.surfaceLight;
        if (_isAnswered) {
          if (isCorrect) {
            buttonColor = AppColors.success;
          } else if (isSelected) {
            buttonColor = AppColors.error;
          }
        }

        Widget button = ElevatedButton(
          onPressed: () => _handleSelect(option),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: _isAnswered && (isCorrect || isSelected)
                ? Colors.black
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              option,
              textAlign: TextAlign.center,
              maxLines: widget.maxOptionLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: option.length > 28
                    ? 11
                    : option.length > 20
                        ? 12
                        : 14,
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
            ),
          ),
        );

        if (_isAnswered && isCorrect) {
          return AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) => Transform.scale(
              scale: _bounceAnimation.value,
              child: child,
            ),
            child: button,
          );
        }

        if (_isAnswered && isSelected && !isCorrect) {
          return AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            ),
            child: button,
          );
        }

        return button;
      }).toList(),
    );
  }
}
