enum AppLang { en, te }

extension AppLangX on AppLang {
  String get code => this == AppLang.te ? 'te' : 'en';
  String get bcp47 => this == AppLang.te ? 'te-IN' : 'en-IN';
  String get label => this == AppLang.te ? 'తెలుగు' : 'English';
}

class S {
  S(this.lang);
  final AppLang lang;
  bool get te => lang == AppLang.te;

  String get appName => te ? 'RoamAgent' : 'RoamAgent';
  String get demoBadge => te ? 'డెమో · అనుకరణ ప్రయాణ డేటా' : 'Demo · Simulated travel data';
  String get landingTitle => te ? 'మీ ప్రయాణాన్ని చెప్పండి' : 'Tell me your journey';
  String get landingSub => te
      ? 'తెలుగు లేదా ఇంగ్లీష్‌లో టైప్ చేయండి లేదా మాట్లాడండి. బస్ షెడ్యూల్స్ అంతర్గత మాక్ డేటా నుంచి వస్తాయి.'
      : 'Type or speak in Telugu or English. Bus schedules come from RoamAgent mock data.';
  String get hint => te
      ? 'ఉదా: రేపు ఉదయం 9 లోపు విశాఖపట్నం నుంచి హైదరాబాద్...'
      : 'e.g. I need to travel from Vizag to Hyderabad tomorrow...';
  String get send => te ? 'పంపండి' : 'Send';
  String get speak => te ? 'మాట్లాడండి' : 'Speak';
  String get listening => te ? 'వింటున్నాం...' : 'Listening...';
  String get reviewTranscript => te ? 'ట్రాన్స్‌క్రిప్ట్ సరిచూసుకోండి' : 'Review transcript';
  String get continueLabel => te ? 'కొనసాగించండి' : 'Continue';
  String get extraction => te ? 'AI Concierge Extraction' : 'AI Concierge Extraction';
  String get reviewTitle => te ? 'ప్రయాణ వివరాలు సమీక్ష' : 'Review trip details';
  String get constraints => te ? 'షెడ్యూల్ నిబంధనలు' : 'Schedule constraints';
  String get searchRoutes => te ? 'మార్గాలు వెతకండి' : 'Search routes';
  String get missing => te ? 'శోధనకు ముందు అవసరమైన ఫీల్డ్‌లు పూరించండి.' : 'Complete required fields before search.';
  String get optionsTitle => te ? 'ఉత్తమ 4 ప్రయాణ ఎంపికలు' : 'Top 4 travel options';
  String get recommended => te ? 'సిఫార్సు' : 'Recommended';
  String get nearMiss => te ? 'నిబంధన ఉల్లంఘన' : 'Constraint miss';
  String get select => te ? 'ఎంచుకోండి' : 'Select';
  String get itinerary => te ? 'ప్రయాణ ప్రణాళిక' : 'Itinerary';
  String get checkout => te ? 'డెమో నిర్ధారణ' : 'Demo confirmation';
  String get pay => te ? 'డెమో చెల్లింపు నిర్ధారించండి' : 'Confirm simulated payment';
  String get noRealPay =>
      te ? 'నిజమైన చెల్లింపు లేదు. టికెట్ బుకింగ్ కాదు.' : 'No real payment. Not an actual ticket booking.';
  String get tracking => te ? 'ప్రయాణం' : 'Journey';
  String get delayBanner => te ? 'కనెక్షన్ ప్రమాదం' : 'Connection at risk';
  String get recovery => te ? 'ప్రత్యామ్నాయ మార్గాలు' : 'Recovery options';
  String get approve => te ? 'ప్రత్యామ్నాయాన్ని ఆమోదించండి' : 'Approve alternative';
  String get reject => te ? 'తిరస్కరించండి' : 'Reject';
  String get original => te ? 'అసలు ప్రణాళిక' : 'Original plan';
  String get proposed => te ? 'ప్రతిపాదన' : 'Proposal';
  String get updated => te ? 'నవీకరించిన ప్రణాళిక' : 'Updated itinerary';
  String get origin => te ? 'మూలం' : 'Origin';
  String get destination => te ? 'గమ్యం' : 'Destination';
  String get date => te ? 'తేదీ' : 'Travel date';
  String get deadline => te ? 'చేరాల్సిన సమయం' : 'Arrival deadline';
  String get travelers => te ? 'ప్రయాణికులు' : 'Travelers';
  String get budget => te ? 'గరిష్ట బడ్జెట్' : 'Max budget';
  String get coach => te ? 'కోచ్' : 'Coach';
  String get berth => te ? 'బెర్త్' : 'Berth';
  String get buffer => te ? 'కనీస ట్రాన్స్‌ఫర్' : 'Min transfer';
  String get noPref => te ? 'ప్రాధాన్యం లేదు' : 'No preference';
  String get fare => te ? 'ఛార్జీ' : 'Fare';
  String get duration => te ? 'వ్యవధి' : 'Duration';
  String get transfers => te ? 'ట్రాన్స్‌ఫర్లు' : 'Transfers';
  String get noneFeasible =>
      te ? 'తప్పనిసరి నిబంధనలకు సరిపోయే మార్గం లేదు.' : 'No itinerary satisfies every mandatory constraint.';
  String get keepRisk =>
      te ? 'అసలు ప్రణాళిక ఉంచబడింది. హెచ్చరిక కనిపిస్తుంది.' : 'Original itinerary kept. Alert remains visible.';
  String get simulatedGps => te ? 'అనుకరణ వాహన స్థానం' : 'Simulated vehicle position';
}
