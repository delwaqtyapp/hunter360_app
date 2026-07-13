import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  String get appName => isArabic ? 'عبقرينو سكادا' : 'Abqarino SCADA';
  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get username => isArabic ? 'اسم المستخدم' : 'Username';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get signIn => isArabic ? 'دخول' : 'SIGN IN';
  String get serverUrl => isArabic ? 'رابط السيرفر' : 'Server URL';
  String get serverConfig => isArabic ? 'إعدادات السيرفر' : 'Server Configuration';
  String get dashboard => isArabic ? 'لوحة التحكم' : 'Dashboard';
  String get controllers => isArabic ? 'وحدات التحكم' : 'Controllers';
  String get diagnostics => isArabic ? 'التشخيص' : 'Diagnostics';
  String get operationCommands => isArabic ? 'أوامر التشغيل' : 'Operation Commands';
  String get operationStatus => isArabic ? 'حالة التشغيل' : 'Operation Status';
  String get schedules => isArabic ? 'جداول الري' : 'Schedules';
  String get alarms => isArabic ? 'الإنذارات' : 'Alarms';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get map => isArabic ? 'الخريطة' : 'Map';
  String get weather => isArabic ? 'الطقس' : 'Weather';
  String get flowManagement => isArabic ? 'إدارة التدفق' : 'Flow Management';
  String get reports => isArabic ? 'التقارير' : 'Reports';
  String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get online => isArabic ? 'متصل' : 'Online';
  String get offline => isArabic ? 'غير متصل' : 'Offline';
  String get manualOperation => isArabic ? 'التشغيل اليدوي' : 'Manual Operation';
  String get start => isArabic ? 'تشغيل' : 'Start';
  String get stop => isArabic ? 'إيقاف' : 'Stop';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get noData => isArabic ? 'لا توجد بيانات' : 'No data available';
  String get loading => isArabic ? 'جاري التحميل...' : 'Loading...';
  String get error => isArabic ? 'خطأ' : 'Error';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get connect => isArabic ? 'اتصال' : 'Connect';
  String get connected => isArabic ? 'متصل بالسيرفر' : 'Connected to server';
  String get disconnected => isArabic ? 'غير متصل' : 'Disconnected';
  String get masterValves => isArabic ? 'الصمامات الرئيسية' : 'Master Valves';
  String get totalActive => isArabic ? 'الإجمالي النشط' : 'Total Active';
  String get activeAlarms => isArabic ? 'الإنذارات النشطة' : 'Active Alarms';
  String get totalTags => isArabic ? 'إجمالي العلامات' : 'Total Tags';
  String get views => isArabic ? 'العروض' : 'Views';
  String get recentAlarms => isArabic ? 'آخر الإنذارات' : 'Recent Alarms';
  String get quickActions => isArabic ? 'إجراءات سريعة' : 'Quick Actions';
  String get controllersList => isArabic ? 'قائمة وحدات التحكم' : 'Controllers List';
  String get tags => isArabic ? 'علامات' : 'tags';
  String get license => isArabic ? 'الرخصة' : 'License';
  String get uploadLicense => isArabic ? 'رفع الرخصة' : 'Upload License';
  String get licensedTo => isArabic ? 'مرخص لـ' : 'Licensed to';
  String get poweredBy => isArabic ? '.powered by Abqarino Technology' : 'Powered by Abqarino Technology';
  String get version => isArabic ? 'الإصدار' : 'Version';
  String get deviceType => isArabic ? 'نوع الجهاز' : 'Device Type';
  String get station => isArabic ? 'محطة' : 'Station';
  String get block => isArabic ? 'بلوك' : 'Block';
  String get pmv => isArabic ? 'صمام' : 'P/MV';
  String get startEvent => isArabic ? 'بدء الحدث' : 'Start Event';
  String get selectController => isArabic ? 'اختر الوحدة' : 'Select Controller';
  String get irrigating => isArabic ? 'يروي' : 'Irrigating';
  String get notIrrigating => isArabic ? 'لا يروي' : 'Not Irrigating';
  String get darkMode => isArabic ? 'الوضع الداكن' : 'Dark Mode';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get noAlarms => isArabic ? 'لا توجد إنذارات' : 'No alarms';
  String get all => isArabic ? 'الكل' : 'All';
  String get critical => isArabic ? 'حرج' : 'Critical';
  String get warning => isArabic ? 'تحذير' : 'Warning';
  String get info => isArabic ? 'معلومات' : 'Info';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
