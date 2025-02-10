import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/utils/enums/feedback_type.dart';

class FeedbackForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController contactController;
  final FeedbackType selectedType;
  final bool wantResponse;
  final Function(FeedbackType) onTypeChange;
  final Function(String) onTitleChange;
  final Function(String) onContentChange;
  final Function(String) onContactChange;
  final Function(bool) onWantResponseChange;

  const FeedbackForm({
    required this.titleController,
    required this.contentController,
    required this.contactController,
    required this.selectedType,
    required this.wantResponse,
    required this.onTypeChange,
    required this.onTitleChange,
    required this.onContentChange,
    required this.onContactChange,
    required this.onWantResponseChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTypeSelector(),
        SizedBox(height: 24.h),
        _buildTitleField(),
        SizedBox(height: 16.h),
        _buildContentField(),
        SizedBox(height: 16.h),
        SwitchListTile(
          title: const Text('Хочу получить ответ'),
          value: wantResponse,
          onChanged: onWantResponseChange,
        ),
        if (wantResponse) ...[
          SizedBox(height: 8.h),
          _buildContactField(),
        ],
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<FeedbackType>(
      segments: FeedbackType.values
          .map((type) => ButtonSegment(
                value: type,
                label: Text(type.label),
                icon: Icon(type.icon),
              ))
          .toList(),
      selected: {selectedType},
      onSelectionChanged: (newSelection) => onTypeChange(newSelection.first),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: titleController,
      decoration: const InputDecoration(
        labelText: 'Краткое описание',
        hintText: 'О чем ваше обращение?',
        border: OutlineInputBorder(),
      ),
      maxLength: 50,
      validator: (v) => v!.isEmpty ? 'Введите заголовок' : null,
      onChanged: onTitleChange,
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: contentController,
      decoration: const InputDecoration(
        labelText: 'Подробное описание',
        hintText: 'Опишите детали...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 5,
      maxLength: 500, // Ограничение на 500 символов
      validator: (v) => v!.isEmpty ? 'Введите содержание' : null,
    );
  }
  Widget _buildContactField() {
    return TextFormField(
      controller: contactController,
      decoration: InputDecoration(
        labelText: 'Контакт для ответа',
        hintText: 'Email или телефон',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          wantResponse ? Icons.contact_page : Icons.help_outline,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: wantResponse
          ? (v) => v!.isEmpty ? 'Введите контактные данные' : null
          : null,
      onChanged: onContactChange,
    );
  }
}
