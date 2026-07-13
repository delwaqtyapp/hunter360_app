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
  String get runningStations => isArabic ? 'المحطات العاملة' : 'Running Stations';
  String get controllersOnline => isArabic ? 'كنترولات متصلة' : 'Controllers Online';
  String get systemStatus => isArabic ? 'حالة النظام' : 'System Status';
  String get liveFlowMeters => isArabic ? 'عدادات التدفق المباشرة' : 'Live Flow Meters';
  String get totalFlow => isArabic ? 'إجمالي التدفق' : 'Total Flow';
  String get notIrrigatingLabel => isArabic ? 'غير مروي' : 'Not Irrigating';
  String get normalLabel => isArabic ? 'طبيعي' : 'Normal';
  String get highLabel => isArabic ? 'مرتفع' : 'High';
  String get lowLabel => isArabic ? 'منخفض' : 'Low';

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
  String get serverUnavailable => isArabic ? 'السيرفر غير متاح - تحقق من اتصال VPN' : 'Server unavailable - check VPN connection';
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

  // --- UI Modernization ---
  String get mainSection => isArabic ? 'الرئيسية' : 'MAIN';
  String get irrigationSection => isArabic ? 'الري' : 'IRRIGATION';
  String get monitoringSection => isArabic ? 'المراقبة' : 'MONITORING';
  String get systemSection => isArabic ? 'النظام' : 'SYSTEM';
  String get connectedToServerStatus => isArabic ? 'متصل' : 'Connected';
  String get notConnectedToServerStatus => isArabic ? 'غير متصل' : 'Offline';
  String get tapToConfigure => isArabic ? 'اضغط للإعداد' : 'Tap to configure';
  String get forgotPassword => isArabic ? 'نسيت كلمة المرور؟' : 'Forgot password?';
  String get rememberMe => isArabic ? 'تذكرني' : 'Remember me';
  String get welcomeBack => isArabic ? 'مرحباً بعودتك' : 'Welcome Back';
  String get loginToContinue => isArabic ? 'سجّل دخولك للمتابعة' : 'Sign in to continue';
  String get trends => isArabic ? 'المنحنى' : 'Trends';
  String get trendLabel => isArabic ? 'المنحنى' : 'Trends';

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
  String get testConnection => isArabic ? 'اختبار الاتصال' : 'Test Connection';
  String get connectionSuccess => isArabic ? 'تم الاتصال بنجاح' : 'Connection successful';
  String get connectionFailed => isArabic ? 'فشل الاتصال' : 'Connection failed';
  String get autoLogoutDisabled => isArabic ? 'معطل' : 'Disabled';
  String get autoLogoutDialog => isArabic ? 'تسجيل الخروج التلقائي' : 'Auto Logout';
  String get selectMinutes => isArabic ? 'اختر عدد الدقائق' : 'Select minutes';
  String get disabled => isArabic ? 'معطل' : 'Disabled';
  String get exportData => isArabic ? 'تصدير البيانات' : 'Export Data';
  String get clearCache => isArabic ? 'مسح الكاش' : 'Clear Cache';
  String get cacheCleared => isArabic ? 'تم مسح الكاش' : 'Cache cleared';
  String get resetToDefaults => isArabic ? 'إعادة الضبط الافتراضي' : 'Reset to Defaults';
  String get resetConfirm => isArabic ? 'هل أنت متأكد من إعادة جميع الإعدادات للقيمة الافتراضية؟' : 'Are you sure you want to reset all settings to defaults?';
  String get settingsReset => isArabic ? 'تم إعادة الضبط' : 'Settings reset';
  String get requiresRestart => isArabic ? 'قد يتطلب إعادة تشغيل التطبيق' : 'App restart may be required';
  String get serverUrlLabel => isArabic ? 'رابط السيرفر' : 'Server URL';
  String get deviceInfo => isArabic ? 'معلومات الجهاز' : 'Device Info';
  String get notificationsEnabledLabel => isArabic ? 'مفعل' : 'Enabled';
  String get notificationsDisabledLabel => isArabic ? 'معطل' : 'Disabled';
  String get settingsSection => isArabic ? 'الإعدادات' : 'Settings';
  String get dangerZone => isArabic ? 'منطقة الخطر' : 'Danger Zone';

  // --- Controllers Extended ---
  String get noControllersFound => isArabic ? 'لا توجد وحدات تحكم' : 'No controllers found';
  String get noControllers => isArabic ? 'لا توجد وحدات تحكم متصلة' : 'No controllers connected';
  String get noFlowData => isArabic ? 'لا توجد بيانات تدفق' : 'No flow data available';
  String get noActiveAlarms => isArabic ? 'لا توجد إنذارات نشطة' : 'No active alarms';
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

  // --- Schedules Advanced ---
  String get weeklySchedule => isArabic ? 'أسبوعي' : 'Weekly';
  String get oddEvenSchedule => isArabic ? 'فردي/زوجي' : 'Odd/Even';
  String get intervalSchedule => isArabic ? 'فترة' : 'Interval';
  String get manualSchedule => isArabic ? 'يدوي' : 'Manual';
  String get noWaterWindowLabel => isArabic ? 'فترة منع الري' : 'No Water Window';
  String get noWaterWindowDesc => isArabic ? 'فترات يكون فيها الري محظوراً' : 'Periods when irrigation is prohibited';
  String get startTimeLabel => isArabic ? 'وقت البدء' : 'Start Time';
  String get endTimeLabel => isArabic ? 'وقت الانتهاء' : 'End Time';
  String get stationDelay => isArabic ? 'تأخير المحطة' : 'Station Delay';
  String get stationDelayDesc => isArabic ? 'التأخير بين المحطات' : 'Delay between stations';
  String get stackMode => isArabic ? 'تتابع' : 'Stack';
  String get overlapMode => isArabic ? 'تراكب' : 'Overlap';
  String get stackOrOverlap => isArabic ? 'تتابع أو تراكب' : 'Stack or Overlap';
  String get stackDesc => isArabic ? 'محطة واحدة في كل مرة' : 'One station at a time';
  String get overlapDesc => isArabic ? 'محطات متزامنة' : 'Concurrent stations';
  String get startTimes => isArabic ? 'أوقات البدء' : 'Start Times';
  String get startTimeNumber => isArabic ? 'وقت البدء' : 'Start Time';
  String get runTimes => isArabic ? 'أوقات التشغيل' : 'Run Times';
  String get runTimeMinutesLabel => isArabic ? 'وقت التشغيل (دقيقة)' : 'Run Time (minutes)';
  String get programMode => isArabic ? 'وضع البرنامج' : 'Program Mode';
  String get autoMode => isArabic ? 'تلقائي' : 'Auto';
  String get manualMode => isArabic ? 'يدوي' : 'Manual';
  String get oddDays => isArabic ? 'أيام فردية' : 'Odd Days';
  String get evenDays => isArabic ? 'أيام زوجية' : 'Even Days';
  String get bothOddEven => isArabic ? 'كلاهما' : 'Both';
  String get intervalDays => isArabic ? 'كل يوم (عدد الأيام)' : 'Interval (days)';
  String get scheduleType => isArabic ? 'نوع الجدول' : 'Schedule Type';

  // --- Flow Advanced ---
  String get learnFlow => isArabic ? 'تعلم التدفق' : 'Learn Flow';
  String get startLearnFlow => isArabic ? 'بدء تعلم التدفق' : 'Start Learn Flow';
  String get stopLearnFlow => isArabic ? 'إيقاف تعلم التدفق' : 'Stop Learn Flow';
  String get learnFlowStatus => isArabic ? 'حالة تعلم التدفق' : 'Learn Flow Status';
  String get idle => isArabic ? 'خامل' : 'Idle';
  String get learning => isArabic ? 'جاري التعلم' : 'Learning';
  String get learnComplete => isArabic ? 'اكتمل التعلم' : 'Complete';
  String get learnFlowResults => isArabic ? 'نتائج تعلم التدفق' : 'Learn Flow Results';
  String get highFlowShutdown => isArabic ? 'إيقاف التدفق المرتفع' : 'High Flow Shutdown';
  String get highFlowShutdownDesc => isArabic ? 'إيقاف تشغيل الري عند تجاوز العتبة' : 'Shutdown when flow exceeds threshold';
  String get shutdownThreshold => isArabic ? 'عتبة الإيقاف (جاليون/دقيقة)' : 'Shutdown Threshold (GPM)';
  String get autoResetTimer => isArabic ? 'مؤقت إعادة التشغيل التلقائي (دقائق)' : 'Auto Reset Timer (minutes)';
  String get shutdownActive => isArabic ? 'الإيقاف نشط' : 'Shutdown Active';
  String get shutdownInactive => isArabic ? 'الإيقاف غير نشط' : 'Shutdown Inactive';
  String get flowZones => isArabic ? 'مناطق التدفق' : 'Flow Zones';
  String get zoneName => isArabic ? 'اسم المنطقة' : 'Zone Name';
  String get flowTarget => isArabic ? 'الهدف (جاليون/دقيقة)' : 'Flow Target (GPM)';
  String get maxFlowLimit => isArabic ? 'الحد الأقصى للتدفق' : 'Max Flow Limit';
  String get overFlowLimit => isArabic ? 'حد التدفق الزائد' : 'Over Flow Limit';
  String get underFlowLimit => isArabic ? 'حد التدفق المنخفض' : 'Under Flow Limit';
  String get unscheduledFlowLimit => isArabic ? 'حد التدفق غير المخطط' : 'Unscheduled Flow Limit';
  String get monthlyBudget => isArabic ? 'الميزانية الشهرية (جاليون)' : 'Monthly Budget (gallons)';
  String get manualAllowance => isArabic ? 'السماحية اليدوية' : 'Manual Allowance';
  String get flowStatusNormal => isArabic ? 'طبيعي' : 'Normal';
  String get flowStatusHigh => isArabic ? 'مرتفع' : 'High';
  String get flowStatusLow => isArabic ? 'منخفض' : 'Low';
  String get cycleAndSoak => isArabic ? 'الدورات والامتصاص' : 'Cycle and Soak';
  String get cycleAndSoakDesc => isArabic ? 'يمنع التسرب عن طريق تدوير الري مع فترات امتصاص' : 'Prevents runoff by cycling irrigation with soak periods';
  String get cycleTime => isArabic ? 'وقت الدورة (دقائق)' : 'Cycle Time (minutes)';
  String get soakTime => isArabic ? 'وقت الامتصاص (دقائق)' : 'Soak Time (minutes)';
  String get flowPriority => isArabic ? 'أولوية التدفق' : 'Flow Priority';
  String get waterSourceFlow => isArabic ? 'تدفق مصدر المياه' : 'Water Source Flow';
  String get totalWaterSourceFlow => isArabic ? 'إجمالي تدفق مصدر المياه' : 'Total Water Source Flow';
  String get flowSensorMap => isArabic ? 'خريطة مستشعرات التدفق' : 'Flow Sensor Map';
  String get gpm => isArabic ? 'جاليون/دقيقة' : 'GPM';
  String get gallons => isArabic ? 'جاليون' : 'gal';

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
  String get yearlyET => isArabic ? 'ET السنوي' : 'Yearly ET';
  String get etBasedOnPenmanMonteith => isArabic ? 'ET بناءً على بانمان-مونتيث' : 'ET based on Penman-Monteith';
  String get weatherHistory => isArabic ? 'سجل الطقس' : 'Weather History';

  // --- Sites ---
  String get sitesTitle => isArabic ? 'المواقع' : 'Sites';
  String get siteId => isArabic ? 'رقم الموقع' : 'Site ID';
  String get siteName => isArabic ? 'اسم الموقع' : 'Site Name';
  String get coordinates => isArabic ? 'الإحداثيات' : 'Coordinates';
  String get controllersCount => isArabic ? 'عدد الكنترولات' : 'Controllers';
  String get stationsCount => isArabic ? 'عدد المحطات' : 'Stations';
  String get flowSensorsCount => isArabic ? 'عدادات التدفق' : 'Flow Sensors';
  String get pmvCount => isArabic ? 'الصمامات' : 'PMVs';
  String get siteStatus => isArabic ? 'حالة الموقع' : 'Site Status';
  String get siteDetails => isArabic ? 'تفاصيل الموقع' : 'Site Details';
  String get latLabel => isArabic ? 'خط العرض' : 'Latitude';
  String get lngLabel => isArabic ? 'خط الطول' : 'Longitude';
  String get tapToNavigate => isArabic ? 'اضغط للانتقال' : 'Tap to navigate';

  // --- Controller Info Tab ---
  String get infoTab => isArabic ? 'المعلومات' : 'Info';
  String get controllerType => isArabic ? 'نوع الكنترولر' : 'Controller Type';
  String get firmwareVersion => isArabic ? 'إصدار البرنامج' : 'Firmware Version';
  String get stationSize => isArabic ? 'حجم المحطات' : 'Station Size';
  String get currentDateTime => isArabic ? 'التاريخ والوقت' : 'Date/Time';
  String get ipAddress => isArabic ? 'عنوان IP' : 'IP Address';
  String get communicationProtocol => isArabic ? 'بروتوكول الاتصال' : 'Communication Protocol';
  String get masterSlaveMode => isArabic ? 'وضع الماستر/سليف' : 'Master/Slave Mode';
  String get controllerTypeLabel => isArabic ? 'النوع' : 'Type';
  String get moduleInformation => isArabic ? 'معلومات الوحدات' : 'Module Information';
  String get currentDraw => isArabic ? 'التيار الكهربائي' : 'Current Draw';
  String get overloadStatus => isArabic ? 'حالة الحمل الزائد' : 'Overload Status';
  String get pathStatus => isArabic ? 'حالة المسار' : 'Path Status';
  String get shutdownStatus => isArabic ? 'حالة الإيقاف' : 'Shutdown';
  String get daysOffStatus => isArabic ? 'أيام الإيقاف' : 'Days Off';
  String get suspendStatus => isArabic ? 'حالة التعليق' : 'Suspend/Pause';
  String get muteStatus => isArabic ? 'حالة الكتم' : 'Mute';
  String get connectionStatistics => isArabic ? 'إحصائيات الاتصال' : 'Connection Statistics';
  String get communicationQuality => isArabic ? 'جودة الاتصال' : 'Communication Quality';
  String get lastCommunication => isArabic ? 'آخر اتصال ناجح' : 'Last Communication';
  String get retryCount => isArabic ? 'عدد المحاولات' : 'Retry Count';
  String get module => isArabic ? 'وحدة' : 'Module';
  String get activeLabel => isArabic ? 'نشط' : 'Active';
  String get noneLabel => isArabic ? 'لا يوجد' : 'None';

  // --- Schedule Editor ---
  String get programLabel => isArabic ? 'البرنامج' : 'Program';
  String get programA => isArabic ? 'البرنامج أ' : 'Program A';
  String get programB => isArabic ? 'البرنامج ب' : 'Program B';
  String get programC => isArabic ? 'البرنامج ج' : 'Program C';
  String get programD => isArabic ? 'البرنامج د' : 'Program D';
  String get daySelection => isArabic ? 'اختيار الأيام' : 'Day Selection';
  String get startTimesLabel => isArabic ? 'أوقات البدء' : 'Start Times';
  String get addStartTime => isArabic ? 'إضافة وقت بدء' : 'Add Start Time';
  String get removeTime => isArabic ? 'إزالة الوقت' : 'Remove time';
  String get stationListLabel => isArabic ? 'قائمة المحطات' : 'Station List';
  String get runTimeMinutes => isArabic ? 'وقت التشغيل (دقائق)' : 'Run Time (min)';
  String get enableDisableLabel => isArabic ? 'تفعيل/تعطيل' : 'Enable/Disable';
  String get scheduleTypeLabel => isArabic ? 'نوع الجدول' : 'Schedule Type';
  String get weeklyLabel => isArabic ? 'أسبوعي' : 'Weekly';
  String get oddEvenLabel => isArabic ? 'فردي/زوجي' : 'Odd/Even';
  String get intervalLabel => isArabic ? 'فترة' : 'Interval';
  String get noWaterWindow => isArabic ? 'فترة عدم الري' : 'No Water Window';
  String get noWaterStart => isArabic ? 'بداية فترة عدم الري' : 'No Water Start';
  String get noWaterEnd => isArabic ? 'نهاية فترة عدم الري' : 'No Water End';
  String get saveSchedule => isArabic ? 'حفظ الجدول' : 'Save Schedule';
  String get scheduleSaved => isArabic ? 'تم حفظ الجدول' : 'Schedule saved';
  String get scheduleEditorTitle => isArabic ? 'محرر الجداول' : 'Schedule Editor';
  String get seasonalIndicator => isArabic ? 'التعديل الموسمي' : 'Seasonal';

  // --- Security / User Management ---
  String get securityTitle => isArabic ? 'الأمان' : 'Security';
  String get userManagement => isArabic ? 'إدارة المستخدمين' : 'User Management';
  String get addUser => isArabic ? 'إضافة مستخدم' : 'Add User';
  String get editUserLabel => isArabic ? 'تعديل المستخدم' : 'Edit User';
  String get deleteUserLabel => isArabic ? 'حذف المستخدم' : 'Delete User';
  String get usernameLabel => isArabic ? 'اسم المستخدم' : 'Username';
  String get pinCode => isArabic ? 'كود PIN' : 'PIN Code';
  String get roleLabelD => isArabic ? 'الدور' : 'Role';
  String get adminRole => isArabic ? 'مدير' : 'Admin';
  String get crewRole => isArabic ? 'طاقم عمل' : 'Crew';
  String get accessLevelD => isArabic ? 'مستوى الوصول' : 'Access Level';
  String get userManagementBypass => isArabic ? 'تجاوز إدارة المستخدمين' : 'User Management Bypass';
  String get factoryResetLabel => isArabic ? 'إعادة الضبط من المصنع' : 'Factory Reset';
  String get dialPositionTitle => isArabic ? 'موضع العدّاد' : 'Dial Position';
  String get userEventsLog => isArabic ? 'سجل أحداث المستخدمين' : 'User Events Log';
  String get recentEvents => isArabic ? 'الأحداث الأخيرة' : 'Recent Events';
  String get enableLabel => isArabic ? 'تفعيل' : 'Enable';
  String get disableLabel => isArabic ? 'تعطيل' : 'Disable';
  String get activeLabelD => isArabic ? 'نشط' : 'Active';
  String get inactiveLabel => isArabic ? 'غير نشط' : 'Inactive';
  String get loginEvent => isArabic ? 'تسجيل الدخول' : 'Login';
  String get logoutEvent => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get runDial => isArabic ? 'تشغيل' : 'Run';
  String get dateTimeDial => isArabic ? 'التاريخ والوقت' : 'Date/Time';
  String get stationRuntimes => isArabic ? 'أوقات تشغيل المحطات' : 'Station Runtimes';
  String get daysToWater => isArabic ? 'أيام الري' : 'Days to Water';
  String get pumpOperation => isArabic ? 'تشغيل المضخة' : 'Pump Operation';
  String get solarSync => isArabic ? 'مزامنة الطاقة الشمسية' : 'Solar Sync';
  String get systemOff => isArabic ? 'إيقاف النظام' : 'System Off';
  String get deleteUserConfirm => isArabic ? 'هل أنت متأكد من حذف هذا المستخدم؟' : 'Are you sure you want to delete this user?';
  String get manualOperationDial => isArabic ? 'التشغيل اليدوي' : 'Manual Operation';
  String get seasonalAdjustmentDial => isArabic ? 'التعديل الموسمي' : 'Seasonal Adjustment';

  // --- Alarm History ---
  String get alarmHistoryTitle => isArabic ? 'سجل الإنذارات' : 'Alarm History';
  String get fromLabel => isArabic ? 'من' : 'From';
  String get toLabel => isArabic ? 'إلى' : 'To';
  String get controllerFilterLabel => isArabic ? 'فلتر الكنترولر' : 'Controller Filter';
  String get priorityFilterLabel => isArabic ? 'فلتر الأولوية' : 'Priority Filter';
  String get totalInPeriod => isArabic ? 'إجمالي الفترة' : 'Total in Period';
  String get mostCommonAlarm => isArabic ? 'أكثر إنذار تكراراً' : 'Most Common Alarm';
  String get avgResolution => isArabic ? 'متوسط وقت الحل' : 'Avg Resolution Time';
  String get hoursUnit => isArabic ? 'ساعة' : 'hrs';
  String get noDataInPeriod => isArabic ? 'لا توجد بيانات في هذه الفترة' : 'No data in this period';
  String get filterByPriority => isArabic ? 'فلترة حسب الأولوية' : 'Filter by Priority';

  // --- Diagnostics Enhanced ---
  String get module1Label => isArabic ? 'الوحدة 1' : 'Module 1';
  String get module2Label => isArabic ? 'الوحدة 2' : 'Module 2';
  String get module3Label => isArabic ? 'الوحدة 3' : 'Module 3';
  String get outputMode => isArabic ? 'وضع الإخراج' : 'Output Mode';
  String get decoderCommunicationTitle => isArabic ? 'اتصال المفكك' : 'Decoder Communication';
  String get commPercentage => isArabic ? 'نسبة الاتصال' : 'Communication %';
  String get totalDecoders => isArabic ? 'إجمالي المفككات' : 'Total Decoders';
  String get activeDecodersCount => isArabic ? 'المفككات النشطة' : 'Active Decoders';
  String get decoderWireTest => isArabic ? 'اختبار أسلاك المفكك' : 'Decoder Wire Test';
  String get blockSettingsTitle => isArabic ? 'إعدادات البلوكات' : 'Block Settings';
  String get cycleSettings => isArabic ? 'إعدادات الدورة' : 'Cycle Settings';
  String get soakSettings => isArabic ? 'إعدادات النقع' : 'Soak Settings';
  String get hydraulicConnection => isArabic ? 'الاتصال الهيدروليكي' : 'Hydraulic Connection';
  String get masterValveAssoc => isArabic ? 'ربط الصمام الرئيسي' : 'Master Valve Association';
  String get linkFlowZone => isArabic ? 'منطقة تدفق الربط' : 'Link Flow Zone';
  String get currentDrawTrend => isArabic ? 'اتجاه التيار الحالي' : 'Current Draw Trend';
  String get overloadLabel => isArabic ? 'حمل زائد' : 'Overload';
  String get normalStatusLabel => isArabic ? 'طبيعي' : 'Normal';
  String get connectedLabel => isArabic ? 'متصل' : 'Connected';
  String get disconnectedLabel => isArabic ? 'غير متصل' : 'Disconnected';
  String get valveLabel => isArabic ? 'صمام' : 'Valve';
  String get blockNumberLabel => isArabic ? 'رقم البلوك' : 'Block No.';
  String get yesLabel => isArabic ? 'نعم' : 'Yes';
  String get noLabel => isArabic ? 'لا' : 'No';
  String get mAUnit => isArabic ? 'ميغا أمبير' : 'mA';
  String get controllerTypeLabelD => isArabic ? 'نوع الكنترولر' : 'Controller Type';
  String get firmwareLabel => isArabic ? 'الإصدار' : 'Firmware';
  String get stationSizeLabelD => isArabic ? 'حجم المحطة' : 'Station Size';
  String get commProtocolLabel => isArabic ? 'بروتوكول الاتصال' : 'Comm Protocol';

  // --- Map Control ---
  String get site => isArabic ? 'موقع' : 'Site';
  String get flowSensor => isArabic ? 'مقياس التدفق' : 'Flow Sensor';
  String get parentController => isArabic ? 'الكنترولر الأب' : 'Parent Controller';
  String get viewDetails => isArabic ? 'عرض التفاصيل' : 'View Details';
  String get latitudeLabel => isArabic ? 'خط العرض' : 'Latitude';
  String get longitudeLabel => isArabic ? 'خط الطول' : 'Longitude';
  String get activeValves => isArabic ? 'صمامات نشطة' : 'Active Valves';
  String get searchMap => isArabic ? 'بحث في الخريطة...' : 'Search map...';
  String get allTypes => isArabic ? 'الكل' : 'All';
  String get sitesLabel => isArabic ? 'المواقع' : 'Sites';
  String get stationsLabel => isArabic ? 'المحطات' : 'Stations';
  String get flowSensorsLabel => isArabic ? 'مقياسات التدفق' : 'Flow Sensors';
  String get pmvsLabel => isArabic ? 'الصمامات' : 'PMVs';
  String get mapLegend => isArabic ? 'دليل الخريطة' : 'Map Legend';
  String get tapMarkerForDetails => isArabic ? 'اضغط على العلامة للتفاصيل' : 'Tap a marker for details';
  String get markersFound => isArabic ? 'علامة موجودة' : 'markers found';
  String get dailyFlow => isArabic ? 'التدفق اليومي' : 'Daily Flow';
  String get weeklyFlow => isArabic ? 'التدفق الأسبوعي' : 'Weekly Flow';
  String get monthlyFlow => isArabic ? 'التدفق الشهري' : 'Monthly Flow';
  String get yearlyFlow => isArabic ? 'التدفق السنوي' : 'Yearly Flow';
  String get flowByZone => isArabic ? 'التدفق حسب المنطقة' : 'Flow by Zone';
  String get trendChart => isArabic ? 'الرسم البياني للاتجاه' : 'Trend Chart';
  String get selectPeriod => isArabic ? 'اختر الفترة' : 'Select Period';
  String get totalFlowLabel => isArabic ? 'إجمالي التدفق' : 'Total Flow';
  String get litersUnit => isArabic ? 'لتر' : 'Liters';
  String get zone5 => isArabic ? 'المنطقة 5' : 'Zone 5';
  String get zone6 => isArabic ? 'المنطقة 6' : 'Zone 6';
  String get flowHistory => isArabic ? 'سجل التدفق' : 'Flow History';
  String get cubicMetersShort => isArabic ? 'م³' : 'm³';
  String get gallonsShort => isArabic ? 'جالون' : 'gal';
  String get zonesLabel => isArabic ? 'مناطق' : 'Zones';

  // --- Trends ---
  String get trendTitle => isArabic ? 'المنحنى' : 'Trends';
  String get trendFlow => isArabic ? 'التدفق' : 'Flow';
  String get trendCurrentDraw => isArabic ? 'التيار' : 'Current Draw';
  String get trendSeasonalAdjust => isArabic ? 'التعديل الموسمي' : 'Seasonal Adjust';
  String get trendFlowChart => isArabic ? 'رسم بياني للتدفق' : 'Flow Trend Chart';
  String get trendCurrentDrawChart => isArabic ? 'رسم بياني للتيار' : 'Current Draw Trend Chart';
  String get trendSeasonalAdjustChart => isArabic ? 'رسم بياني للتعديل الموسمي' : 'Seasonal Adjust Trend Chart';
  String get timeRangeLabel => isArabic ? 'النطاق الزمني' : 'Time Range';
  String get trendMin => isArabic ? 'الحد الأدنى' : 'Min';
  String get trendMax => isArabic ? 'الحد الأقصى' : 'Max';
  String get trendAverage => isArabic ? 'المتوسط' : 'Average';
  String get trendActiveTags => isArabic ? 'العلامات النشطة' : 'Active Tags';

  // --- Solar Sync ---
  String get solarSyncTitle => isArabic ? 'Solar Sync' : 'Solar Sync';
  String get solarSyncSettings => isArabic ? 'إعدادات Solar Sync' : 'Solar Sync Settings';
  String get solarSyncEnableSensor => isArabic ? 'تفعيل المستشعر' : 'Enable Sensor';
  String get solarSyncEnableSensorDesc => isArabic ? 'تشغيل/إيقاف مستشعر الطقس الذكي' : 'Toggle smart weather sensor';
  String get solarSyncRegion => isArabic ? 'المنطقة' : 'Region';
  String get solarSyncRegionLabel => isArabic ? 'المنطقة' : 'Region';
  String get solarSyncWaterAdjustment => isArabic ? 'معامل تعديل المياه' : 'Water Adjustment Factor';
  String get solarSyncDelayDays => isArabic ? 'أيام التأخير' : 'Delay Days';
  String get solarSyncDelayDaysDesc => isArabic ? 'تأخير التعديل بعد هطول الأمطار' : 'Delay adjustment after rainfall';
  String get solarSyncAdjDuringDelay => isArabic ? 'التعديل أثناء التأخير' : 'Adjustment During Delay';
  String get solarSyncAdjDuringDelayDesc => isArabic ? 'تطبيق التعديل أثناء فترة التأخير' : 'Apply adjustment during delay period';
  String get solarSyncReadings => isArabic ? 'القراءات الحية' : 'Live Readings';
  String get solarSyncLive => isArabic ? 'مباشر' : 'LIVE';
  String get solarRadiation => isArabic ? 'الإشعاع الشمسي' : 'Solar Radiation';
  String get solarSyncETHistory => isArabic ? 'سجل ET' : 'ET History';
  String get solarSyncSaveSuccess => isArabic ? 'تم حفظ الإعدادات بنجاح' : 'Settings saved successfully';
  String get solarSyncSaveError => isArabic ? 'خطأ في حفظ الإعدادات' : 'Error saving settings';

  // --- ET Calculation ---
  String get etCalculationTitle => isArabic ? 'حساب ET' : 'ET Calculation';
  String get etCurrentETo => isArabic ? 'التبخر-النتح الحالي (ETo)' : 'Current ETo';
  String get etPenmanMonteith => isArabic ? 'بانمان-مونتيث' : 'Penman-Monteith';
  String get etCalculatedETo => isArabic ? 'ETo المحسوب' : 'Calculated ETo';
  String get etAccumulation => isArabic ? 'تراكم ET' : 'ET Accumulation';
  String get etTrendChart => isArabic ? 'رسم بياني لـ ET' : 'ET Trend Chart';
  String get etReport => isArabic ? 'تقرير ET' : 'ET Report';
  String get etValidDays => isArabic ? 'أيام ET الصالحة' : 'Valid ET Days';
  String get etAverage => isArabic ? 'متوسط ET' : 'ET Average';
  String get etLast7Days => isArabic ? 'ET آخر 7 أيام' : 'ET Last 7 Days';
  String get etLast30Days => isArabic ? 'ET آخر 30 يوم' : 'ET Last 30 Days';
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
