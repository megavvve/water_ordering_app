import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/screens/feedback_screen/widgets/feedback_form.dart';
import 'package:vodovoz/domain/entities/feedback.dart' as f;
import 'package:vodovoz/utils/enums/feedback_type.dart';
import 'package:appwrite/appwrite.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  FeedbackScreenState createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contactController = TextEditingController();
  FeedbackType _selectedType = FeedbackType.suggestion;
  bool _wantResponse = false;

  AppWrite feedbackService = getIt<AppWrite>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Показать уведомление, если поле заголовка пустое
      if (_titleController.text.isEmpty) {
        Fluttertoast.showToast(
          msg: "Введите заголовок для отзыва",  
          toastLength: Toast.LENGTH_SHORT,  
          gravity: ToastGravity.BOTTOM, 
          timeInSecForIosWeb: 1,  
          backgroundColor: Colors.grey,  
          textColor: Colors.white, 
          fontSize: 16.0.sp,  
        );
      }
      return;
    }

    final feedback = f.Feedback(
      feedbackId: ID.unique(),
      type: _selectedType.name,
      title: _titleController.text,
      content: _contentController.text,
      contact: _contactController.text,
      wantResponse: _wantResponse,
      userId: getIt<LocalSavedData>().getUserId()
    );

    await feedbackService.sendFeedback(feedback);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Спасибо! Ваше обращение отправлено'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обратная связь')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: FeedbackForm(
                titleController: _titleController,
                contentController: _contentController,
                contactController: _contactController,
                selectedType: _selectedType,
                wantResponse: _wantResponse,
                onTypeChange: (newType) =>
                    setState(() => _selectedType = newType),
                onTitleChange: (title) {},
                onContentChange: (content) {},
                onContactChange: (contact) {},
                onWantResponseChange: (value) =>
                    setState(() => _wantResponse = value),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 300.w,
              child: ElevatedButton(
                
                onPressed:_submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: const Text('Отправить'),
              ),
            ),
          ],
        ),
      ),
    );
  }


 
}
