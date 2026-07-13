import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];
  bool get isArabic => locale.languageCode == 'ar';

  // --- General ---
  String get appName => isArabic ? 'عبقرينو سكادا' : 'Abqarino SCADA';
  String get company => isArabic ? 'عبقرينو تكنولوجى' : 'Abqarino Technology';
  String get version => isArabic ? 'الإصدار' : 'Version';
  String get poweredBy => isArabic ? 'powered by عبقرينو تكنولوجى' : 'Powered by Abqarino Technology';

  // --- Auth ---
  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get username => isArabic ? 'اسم المستخدم' : 'Username';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get signIn => isArabic ? 'دخول' : 'SIGN IN';
  String get serverUrl => isArabic ? 'رابط السيرفر' : 'Server URL';
  String get serverConfig => isArabic ? 'إعدادات السيرفر' : 'Server Configuration';
  String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get license => isArabic ? 'الرخصة' : 'License';
  String get uploadLicense => isArabic ? 'رفع الرخصة' : 'Upload License';
  String get licensedTo => isArabic ? 'مرخص لـ' : 'Licensed to';

  // --- Navigation ---
  String get dashboard => isArabic ? 'لوحة التحكم' : 'Dashboard';
  String get controllers => isArabic ? 'وحدات التحكم' : 'Controllers';
  String get schedules => isArabic ? 'جداول الري' : 'Schedules';
  String get alarms => isArabic ? 'الإنذارات' : 'Alarms';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get map => isArabic ? 'الخريطة' : 'Map';
  String get weather => isArabic ? 'الطقس' : 'Weather';
  String get flowManagement => isArabic ? 'إدارة التدفق' : 'Flow Management';
  String get reports => isArabic ? 'التقارير' : 'Reports';
  String get mapControl => isArabic ? 'التحكم بالخريطة' : 'Map Control';

  // --- SCADA Views ---
  String get diagnostics => isArabic ? 'التشخيص' : 'Diagnostics';
  String get operationCommands => isArabic ? 'أوامر التشغيل' : 'Operation Commands';
  String get operationStatus => isArabic ? 'حالة التشغيل' : 'Operation Status';

  // --- Dashboard ---
  String get online => isArabic ? 'متصل' : 'Online';
  String get offline => isArabic ? 'غير متصل' : 'Offline';
  String get activeAlarms => isArabic ? 'إنذارات نشطة' : 'Active Alarms';
  String get totalTags => isArabic ? 'إجمالي العلامات' : 'Total Tags';
  String get quickActions => isArabic ? 'إجراءات سريعة' : 'Quick Actions';
  String get recentAlarms => isArabic ? 'آخر الإنذارات' : 'Recent Alarms';
  String get controllersList => isArabic ? 'قائمة وحدات التحكم' : 'Controllers List';
  String get project => isArabic ? 'المشروع' : 'Project';
  String get controllerName => isArabic ? 'اسم الكنترولر' : 'Controller';
  String get tagsCount => isArabic ? 'علامة' : 'tags';
  String get status => isArabic ? 'الحالة' : 'Status';
  String get viewAll => isArabic ? 'عرض الكل' : 'View All';
  String get projectControllers => isArabic ? 'كنترولات المشروع' : 'Project Controllers';

  // --- Controller Status ---
  String get controllerOnline => isArabic ? 'كنترولر متصل' : 'Controller Online';
  String get controllerOffline => isArabic ? 'كنترولر غير متصل' : 'Controller Offline';
  String get controllerAlarm => isArabic ? 'إنذارات الكنترولر' : 'Controller Alarm';
  String get controllerInfo => isArabic ? 'معلومات الكنترولر' : 'Controller Information';

  // --- Operation Commands ---
  String get manualOperation => isArabic ? 'التشغيل اليدوي' : 'Manual Operation';
  String get startEvent => isArabic ? 'بدء الحدث' : 'Start Event';
  String get start => isArabic ? 'تشغيل' : 'START';
  String get stop => isArabic ? 'إيقاف' : 'STOP';
  String get deviceType => isArabic ? 'نوع الجهاز' : 'Device Type';
  String get station => isArabic ? 'محطة' : 'Station';
  String get block => isArabic ? 'بلوك' : 'Block';
  String get pmv => isArabic ? 'صمام' : 'P/MV';
  String get stationNumber => isArabic ? 'رقم المحطة' : 'Station Number';
  String get blockNumber => isArabic ? 'رقم البلوك' : 'Block Number';
  String get pmvNumber => isArabic ? 'رقم الصمام' : 'P/MV Number';
  String get durationMinutes => isArabic ? 'المدة (دقيقة)' : 'Duration (minutes)';
  String get selectController => isArabic ? 'اختر الكنترولر' : 'Select Controller';
  String get commandSent => isArabic ? 'تم إرسال الأمر' : 'Command sent';

  // --- Operation Status ---
  String get masterValves => isArabic ? 'الصمامات الرئيسية' : 'Master Valves';
  String get irrigating => isArabic ? 'جاري الري' : 'IRRIGATING';
  String get notIrrigating => isArabic ? 'متوقف عن الري' : 'NOT IRRIGATING';
  String get activeAlarmCount => isArabic ? 'إنذارات نشطة' : 'Active Alarms';
  String get totalAlarmCount => isArabic ? 'إجمالي الإنذارات' : 'Total Alarms';
  String get alarmStatus => isArabic ? 'حالة الإنذارات' : 'Alarm Status';
  String get controllerNumber => isArabic ? 'رقم الكنترولر' : 'Controller No.';
  String get projectLabel => isArabic ? 'المشروع' : 'Project';

  // --- Common ---
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
  String get totalActive => isArabic ? 'الإجمالي النشط' : 'Total Active';
  String get views => isArabic ? 'العروض' : 'Views';
  String get darkMode => isArabic ? 'الوضع الداكن' : 'Dark Mode';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get all => isArabic ? 'الكل' : 'All';
  String get critical => isArabic ? 'حرج' : 'Critical';
  String get warning => isArabic ? 'تحذير' : 'Warning';
  String get info => isArabic ? 'معلومات' : 'Info';
  String get noAlarms => isArabic ? 'لا توجد إنذارات' : 'No alarms';
  String get irrigatingStatus => isArabic ? 'حالة الري' : 'Irrigation Status';
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
