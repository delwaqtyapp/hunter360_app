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

  // --- Alarms ---
  String get searchAlarms => isArabic ? 'بحث في الإنذارات...' : 'Search alarms...';
  String get alarmCount => isArabic ? 'عدد الإنذارات' : 'Alarm Count';
  String get priority => isArabic ? 'الأولوية' : 'Priority';
  String get tag => isArabic ? 'العلامة' : 'Tag';
  String get time => isArabic ? 'الوقت' : 'Time';
  String get acknowledged => isArabic ? 'تم التأكيد' : 'Acknowledged';
  String get acknowledge => isArabic ? 'تأكيد' : 'Ack';
  String get allControllers => isArabic ? 'جميع الكنترولات' : 'All Controllers';
  String get allPriorities => isArabic ? 'جميع الأولويات' : 'All Priorities';
  String get noAlarmsFound => isArabic ? 'لا توجد إنذارات مطابقة' : 'No matching alarms found';
  String get pullToRefresh => isArabic ? 'اسحب للتحديث' : 'Pull to refresh';
  String get alarmMessage => isArabic ? 'رسالة الإنذار' : 'Alarm Message';
  String get alarmController => isArabic ? 'كنترولر الإنذار' : 'Alarm Controller';
  String get alarmTime => isArabic ? 'وقت الإنذار' : 'Alarm Time';
  String get alarmTag => isArabic ? 'علامة الإنذار' : 'Alarm Tag';
  String get alarmPriority => isArabic ? 'أولوية الإنذار' : 'Alarm Priority';
  String get ackStatus => isArabic ? 'حالة التأكيد' : 'Ack Status';
  String get unacknowledged => isArabic ? 'غير مؤكد' : 'Unacknowledged';

  // --- Reports ---
  String get waterUsage => isArabic ? 'استهلاك المياه' : 'Water Usage';
  String get waterUsageDesc => isArabic ? 'تحليل استهلاك المياه اليومي والأسبوعي والشهري' : 'Daily, Weekly, Monthly water consumption analysis';
  String get controllerStatus => isArabic ? 'حالة الكنترولر' : 'Controller Status';
  String get controllerStatusDesc => isArabic ? 'حالة الكنترولر وأداء الوحدات' : 'Controller status and performance metrics';
  String get alarmHistory => isArabic ? 'سجل الإنذارات' : 'Alarm History';
  String get alarmHistoryDesc => isArabic ? 'سجل الإنذارات وأوقات الحل' : 'Alarm history and resolution times';
  String get scheduleReport => isArabic ? 'تقرير الجداول' : 'Schedule Report';
  String get scheduleReportDesc => isArabic ? 'تنفيذ الجداول والامتثال' : 'Schedule execution and compliance';
  String get dateRange => isArabic ? 'نطاق التاريخ' : 'Date Range';
  String get fromDate => isArabic ? 'من تاريخ' : 'From Date';
  String get toDate => isArabic ? 'إلى تاريخ' : 'To Date';
  String get exportPDF => isArabic ? 'تصدير PDF' : 'Export PDF';
  String get exportCSV => isArabic ? 'تصدير CSV' : 'Export CSV';
  String get chartPreview => isArabic ? 'معاينة الرسم البياني' : 'Chart Preview';
  String get selectReportType => isArabic ? 'اختر نوع التقرير' : 'Select report type';
  String get noDataAvailable => isArabic ? 'لا توجد بيانات متاحة' : 'No data available';
  String get weeklyUsage => isArabic ? 'الاستهلاك الأسبوعي' : 'Weekly Usage';
  String get monday => isArabic ? 'الاثنين' : 'Mon';
  String get tuesday => isArabic ? 'الثلاثاء' : 'Tue';
  String get wednesday => isArabic ? 'الأربعاء' : 'Wed';
  String get thursday => isArabic ? 'الخميس' : 'Thu';
  String get friday => isArabic ? 'الجمعة' : 'Fri';
  String get saturday => isArabic ? 'السبت' : 'Sat';
  String get sunday => isArabic ? 'الأحد' : 'Sun';
  String get cubicMeters => isArabic ? 'م³' : 'm³';

  // --- Settings Extended ---
  String get generalSettings => isArabic ? 'الإعدادات العامة' : 'General Settings';
  String get aboutSection => isArabic ? 'حول التطبيق' : 'About';
  String get notificationSettingsSection => isArabic ? 'إعدادات الإشعارات' : 'Notification Settings';
  String get autoLogoutSetting => isArabic ? 'تسجيل الخروج التلقائي' : 'Auto Logout';
  String get autoLogoutMinutes => isArabic ? 'مؤقت تسجيل الخروج (دقائق)' : 'Auto Logout Timer (minutes)';
  String get minutesUnit => isArabic ? 'دقيقة' : 'min';
  String get streamServerLabel => isArabic ? 'رابط سيرفر الستريم' : 'Stream Server URL';
  String get connectedToServer => isArabic ? 'متصل بالسيرفر' : 'Connected';
  String get notConnectedToServer => isArabic ? 'غير متصل' : 'Not Connected';
  String get roleLabel => isArabic ? 'الدور' : 'Role';
  String get accessLevelLabel => isArabic ? 'مستوى الوصول' : 'Access Level';
  String get notificationsComingSoon => isArabic ? 'سيتم إعداد الإشعارات قريباً' : 'Notifications will be configured soon';
  String get versionLabel => isArabic ? 'الإصدار' : 'Version';
  String get licensedToLabel => isArabic ? 'مرخص لـ' : 'Licensed to';
  String get companyName => isArabic ? 'عبقرينو تكنولوجى' : 'Abqarino Technology';

  // --- Controllers Extended ---
  String get noControllersFound => isArabic ? 'لا توجد وحدات تحكم' : 'No controllers found';
  String get tapToViewDetails => isArabic ? 'اضغط لعرض التفاصيل' : 'Tap to view details';
  String get stationsTab => isArabic ? 'المحطات' : 'Stations';
  String get blocksTab => isArabic ? 'البلوكات' : 'Blocks';
  String get alarmsTab => isArabic ? 'الإنذارات' : 'Alarms';
  String get manualTab => isArabic ? 'التشغيل اليدوي' : 'Manual';
  String get flowRateLabel => isArabic ? 'معدل التدفق' : 'Flow Rate';
  String get totalStationsLabel => isArabic ? 'إجمالي المحطات' : 'Total Stations';
  String get openStationsLabel => isArabic ? 'محطات مفتوحة' : 'Open Stations';
  String get noStationsFound => isArabic ? 'لا توجد محطات' : 'No stations found';
  String get noBlocksFound => isArabic ? 'لا توجد بلوكات' : 'No blocks found';
  String get controllerDetailTitle => isArabic ? 'تفاصيل الكنترولر' : 'Controller Detail';
  String get tagCountLabel => isArabic ? 'عدد العلامات' : 'Tag Count';
  String get controllerStatusLabel => isArabic ? 'حالة الكنترولر' : 'Controller Status';
  String get litersPerMinute => isArabic ? 'لتر/دقيقة' : 'L/min';
  String get closedStationsLabel => isArabic ? 'محطات مغلقة' : 'Closed Stations';
  String get open => isArabic ? 'مفتوح' : 'Open';
  String get closed => isArabic ? 'مغلق' : 'Closed';
  String get controllerId => isArabic ? 'رقم الكنترولر' : 'Controller ID';
  String get about => isArabic ? 'حول التطبيق' : 'About';
  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get appVersion => isArabic ? 'إصدار التطبيق' : 'App Version';

  // --- Flow Management ---
  String get controller => isArabic ? 'الكنترولر' : 'Controller';
  String get flowOverview => isArabic ? 'نظرة عامة على التدفق' : 'Flow Overview';
  String get totalFlowRate => isArabic ? 'إجمالي معدل التدفق' : 'Total Flow Rate';
  String get activeFlowMeters => isArabic ? 'عدادات التدفق النشطة' : 'Active Flow Meters';
  String get normal => isArabic ? 'طبيعي' : 'Normal';
  String get flowChart => isArabic ? 'رسم بياني للتدفق' : 'Flow Chart';
  String get flowMeters => isArabic ? 'عدادات التدفق' : 'Flow Meters';
  String get active => isArabic ? 'نشط' : 'Active';
  String get flowing => isArabic ? 'جاري التدفق' : 'Flowing';
  String get stopped => isArabic ? 'متوقف' : 'Stopped';
  String get thresholdSettings => isArabic ? 'إعدادات العتبات' : 'Threshold Settings';
  String get minimumFlow => isArabic ? 'الحد الأدنى للتدفق' : 'Minimum Flow';
  String get maximumFlow => isArabic ? 'الحد الأقصى للتدفق' : 'Maximum Flow';
  String get saveThresholds => isArabic ? 'حفظ العتبات' : 'Save Thresholds';
  String get lowFlowAlert => isArabic ? 'إنذار تدفق منخفض' : 'Low Flow Alert';
  String get flowBelowThreshold => isArabic ? 'التدفق أقل من العتبة' : 'Flow below threshold';
  String get ago => isArabic ? 'منذ' : 'ago';
  String get highFlowAlert => isArabic ? 'إنذار تدفق مرتفع' : 'High Flow Alert';
  String get flowAboveNormal => isArabic ? 'التدفق أعلى من الطبيعي' : 'Flow above normal';
  String get flowAlerts => isArabic ? 'إنذارات التدفق' : 'Flow Alerts';
  String get noAlerts => isArabic ? 'لا توجد إنذارات' : 'No Alerts';
  String get errorLoadingData => isArabic ? 'خطأ في تحميل البيانات' : 'Error loading data';
  String get projectName => isArabic ? 'اسم المشروع' : 'Project Name';

  // --- Schedules ---
  String get seasonalAdjustment => isArabic ? 'التعديل الموسمي' : 'Seasonal Adjustment';
  String get minimum => isArabic ? 'الحد الأدنى' : 'Minimum';
  String get recommended100 => isArabic ? 'موصى به 100%' : 'Recommended 100%';
  String get maximum => isArabic ? 'الحد الأقصى' : 'Maximum';
  String get daysOfWeek => isArabic ? 'أيام الأسبوع' : 'Days of Week';
  String get blocks => isArabic ? 'البلوكات' : 'Blocks';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get duplicate => isArabic ? 'تكرار' : 'Duplicate';
  String get noPrograms => isArabic ? 'لا توجد برامج' : 'No Programs';
  String get tapToAddProgram => isArabic ? 'اضغط لإضافة برنامج' : 'Tap to add a program';
  String get addProgram => isArabic ? 'إضافة برنامج' : 'Add Program';
  String get programName => isArabic ? 'اسم البرنامج' : 'Program Name';
  String get startTime => isArabic ? 'وقت البدء' : 'Start Time';
  String get add => isArabic ? 'إضافة' : 'Add';

  // --- Weather ---
  String get weatherStation => isArabic ? 'محطة الطقس' : 'Weather Station';
  String get currentConditions => isArabic ? 'الظروف الحالية' : 'Current Conditions';
  String get temperature => isArabic ? 'درجة الحرارة' : 'Temperature';
  String get humidity => isArabic ? 'الرطوبة' : 'Humidity';
  String get windSpeed => isArabic ? 'سرعة الرياح' : 'Wind Speed';
  String get rainfall => isArabic ? 'هطول الأمطار' : 'Rainfall';
  String get zone1 => isArabic ? 'المنطقة 1' : 'Zone 1';
  String get zone2 => isArabic ? 'المنطقة 2' : 'Zone 2';
  String get zone3 => isArabic ? 'المنطقة 3' : 'Zone 3';
  String get zone4 => isArabic ? 'المنطقة 4' : 'Zone 4';
  String get soilMoisture => isArabic ? 'رطوبة التربة' : 'Soil Moisture';
  String get evapotranspiration => isArabic ? 'التبخر-النتح' : 'Evapotranspiration';
  String get dailyET => isArabic ? 'ET اليومي' : 'Daily ET';
  String get weeklyET => isArabic ? 'ET الأسبوعي' : 'Weekly ET';
  String get monthlyET => isArabic ? 'ET الشهري' : 'Monthly ET';
  String get etBasedOnPenmanMonteith => isArabic ? 'ET بناءً على بانمان-مونتيث' : 'ET based on Penman-Monteith';
  String get weatherHistory => isArabic ? 'سجل الطقس' : 'Weather History';
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
