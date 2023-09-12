{ !NAME:      iPhone - MMC DB.pas }
{ !DESC:      MMCMobile Country Codes, MNCMobile Network Codes }
{ !AUTHOR:    GetData }

{ !Source:
  The International Public Telecommunication Numbering Plan
  ITU Operational Bulletin
  www.itu.int/itu-t/bulletin
  No. 1056 15.VII 2014Information received by 1 July 2014 ISSN 1564-5223Online }

unit Phone_MMC_DB;

interface

uses
  Classes, SysUtils, Graphics, Math, DataEntry, DataStorage, Common;

function MMC_Loookup_Country(countrycode: Integer): string;
function MMC_Loookup_Network(countrycode, networkcode: Integer): string;

implementation

function MMC_Loookup_Country(countrycode: Integer): string;
begin
  Result := '';

  case countrycode of
    412:
      Result := 'Afghanistan'; // Done
    276:
      Result := 'Albania'; // Done
    603:
      Result := 'Algeria'; // Done
    213:
      Result := 'Andorra'; // Done
    631:
      Result := 'Angola'; // Done
    365:
      Result := 'Anguilla';
    344:
      Result := 'Antigua and Barbuda';
    722:
      Result := 'Argentina'; // Done
    363:
      Result := 'Aruba';
    505:
      Result := 'Australia'; // Done
    232:
      Result := 'Austria';
    400:
      Result := 'Azerbaijan';
    426:
      Result := 'Bahrain';
    470:
      Result := 'Bangladesh';
    342:
      Result := 'Barbados';
    257:
      Result := 'Belarus';
    206:
      Result := 'Belgium';
    702:
      Result := 'Belize';
    350:
      Result := 'Bermuda';
    402:
      Result := 'Bhutan';
    736:
      Result := 'BoliviaPlurinational State of';
    218:
      Result := 'Bosnia and Herzegovina';
    652:
      Result := 'Botswana';
    724:
      Result := 'Brazil';
    348:
      Result := 'British Virgin Islands';
    528:
      Result := 'Brunei Darussalam';
    284:
      Result := 'Bulgaria';
    613:
      Result := 'Burkina Faso';
    642:
      Result := 'Burundi';
    625:
      Result := 'Cabo Verde';
    456:
      Result := 'Cambodia';
    624:
      Result := 'Cameroon';
    302:
      Result := 'Canada'; // Done
    346:
      Result := 'Cayman Islands';
    622:
      Result := 'Chad';
    730:
      Result := 'Chile';
    460:
      Result := 'China'; // Done
    732:
      Result := 'Colombia';
    654:
      Result := 'Comoros';
    629:
      Result := 'Congo';
    548:
      Result := 'Cook Islands';
    712:
      Result := 'Costa Rica';
    612:
      Result := 'Côte dIvoire';
    219:
      Result := 'Croatia';
    368:
      Result := 'Cuba';
    362:
      Result := 'Curaçao';
    230:
      Result := 'Czech Rep.';
    630:
      Result := 'Dem. Rep. of the Congo';
    238:
      Result := 'Denmark';
    366:
      Result := 'Dominica';
    370:
      Result := 'Dominican Rep.';
    740:
      Result := 'Ecuador';
    602:
      Result := 'Egypt';
    706:
      Result := 'El Salvador';
    627:
      Result := 'Equatorial Guinea';
    248:
      Result := 'Estonia';
    636:
      Result := 'Ethiopia';
    750:
      Result := 'Falkland IslandsMalvinas';
    274:
      Result := 'Faroe Islands';
    542:
      Result := 'Fiji';
    244:
      Result := 'Finland';
    208:
      Result := 'France'; // Done
    647:
      Result := 'French Departments and Territories in the Indian Ocean';
    340:
      Result := 'French Guiana';
    547:
      Result := 'French Polynesia';
    628:
      Result := 'Gabon';
    282:
      Result := 'Georgia';
    262:
      Result := 'Germany'; // Done
    620:
      Result := 'Ghana';
    266:
      Result := 'Gibraltar';
    202:
      Result := 'Greece';
    290:
      Result := 'Greenland';
    352:
      Result := 'Grenada';
    340:
      Result := 'Guadeloupe';
    704:
      Result := 'Guatemala';
    611:
      Result := 'Guinea';
    632:
      Result := 'Guinea-Bissau';
    738:
      Result := 'Guyana';
    372:
      Result := 'Haiti';
    708:
      Result := 'Honduras';
    454:
      Result := 'Hong Kong, China'; // Done
    216:
      Result := 'Hungary';
    274:
      Result := 'Iceland';
    404:
      Result := 'India'; // Partial
    405:
      Result := 'India';
    510:
      Result := 'Indonesia'; // Done
    432:
      Result := 'IranIslamic Republic of';
    418:
      Result := 'Iraq'; // Done
    272:
      Result := 'Ireland';
    425:
      Result := 'Israel';
    222:
      Result := 'Italy';
    338:
      Result := 'Jamaica';
    440:
      Result := 'Japan';
    441:
      Result := 'Japan';
    416:
      Result := 'Jordan';
    401:
      Result := 'Kazakhstan';
    639:
      Result := 'Kenya';
    450:
      Result := 'KoreaRep. of';
    419:
      Result := 'Kuwait';
    437:
      Result := 'Kyrgyzstan';
    457:
      Result := 'Lao P.D.R.';
    247:
      Result := 'Latvia';
    415:
      Result := 'Lebanon';
    651:
      Result := 'Lesotho';
    618:
      Result := 'Liberia';
    228:
      Result := 'Liechtenstein	';
    246:
      Result := 'Lithuania';
    270:
      Result := 'Luxembourg';
    455:
      Result := 'Macao, China';
    646:
      Result := 'Madagascar';
    650:
      Result := 'Malawi';
    502:
      Result := 'Malaysia';
    472:
      Result := 'Maldives';
    610:
      Result := 'Mali';
    278:
      Result := 'Malta';
    340:
      Result := 'Martinique';
    609:
      Result := 'Mauritania';
    617:
      Result := 'Mauritius';
    334:
      Result := 'Mexico'; // Done
    550:
      Result := 'Micronesia';
    259:
      Result := 'MoldovaRepublic of';
    428:
      Result := 'Mongolia';
    297:
      Result := 'Montenegro';
    354:
      Result := 'Montserrat';
    604:
      Result := 'Morocco';
    643:
      Result := 'Mozambique';
    414:
      Result := 'Myanmar';
    649:
      Result := 'Namibia';
    542:
      Result := 'Nauru';
    429:
      Result := 'Nepal';
    204:
      Result := 'Netherlands';
    546:
      Result := 'New Caledonia';
    530:
      Result := 'New Zealand'; // Done
    710:
      Result := 'Nicaragua';
    614:
      Result := 'Niger';
    621:
      Result := 'Nigeria';
    555:
      Result := 'Niue';
    242:
      Result := 'Norway';
    422:
      Result := 'Oman'; // Done
    410:
      Result := 'Pakistan';
    552:
      Result := 'Palau';
    714:
      Result := 'Panama';
    537:
      Result := 'Papua New Guinea';
    744:
      Result := 'Paraguay';
    716:
      Result := 'Peru';
    515:
      Result := 'Philippines';
    260:
      Result := 'Poland';
    268:
      Result := 'Portugal';
    427:
      Result := 'Qatar';
    226:
      Result := 'Romania';
    250:
      Result := 'Russian Federation'; // Done
    635:
      Result := 'Rwanda';
    356:
      Result := 'Saint Kitts and Nevis';
    358:
      Result := 'Saint Lucia';
    308:
      Result := 'Saint Pierre and Miquelon';
    360:
      Result := 'Saint Vincent and the Grenadines';
    549:
      Result := 'Samoa';
    292:
      Result := 'San Marino';
    626:
      Result := 'Sao Tome and Principe';
    420:
      Result := 'Saudi Arabia';
    608:
      Result := 'Senegal';
    220:
      Result := 'Serbia';
    633:
      Result := 'Seychelles';
    619:
      Result := 'Sierra Leone';
    525:
      Result := 'Singapore'; // Done
    231:
      Result := 'Slovakia';
    293:
      Result := 'Slovenia';
    540:
      Result := 'Solomon Islands';
    655:
      Result := 'South Africa'; // Done
    659:
      Result := 'South Sudan';
    214:
      Result := 'Spain'; // Done
    413:
      Result := 'Sri Lanka';
    634:
      Result := 'Sudan';
    746:
      Result := 'Suriname';
    653:
      Result := 'Swaziland';
    240:
      Result := 'Sweden';
    228:
      Result := 'Switzerland'; // Done
    417:
      Result := 'Syrian Arab Republic';
    436:
      Result := 'Tajikistan';
    640:
      Result := 'Tanzania';
    520:
      Result := 'Thailand';
    294:
      Result := 'The Former Yugoslav Republic of Macedonia';
    514:
      Result := 'Timor-Leste';
    615:
      Result := 'Togo';
    539:
      Result := 'Tonga';
    374:
      Result := 'Trinidad and Tobago';
    605:
      Result := 'Tunisia';
    286:
      Result := 'Turkey'; // Done
    438:
      Result := 'Turkmenistan';
    376:
      Result := 'Turks and Caicos Islands';
    553:
      Result := 'Tuvalu';
    641:
      Result := 'Uganda';
    255:
      Result := 'Ukraine';
    424:
      Result := 'United Arab Emirates';
    234:
      Result := 'United Kingdom'; // Done
    310:
      Result := 'USA'; // Done
    748:
      Result := 'Uruguay';
    334:
      Result := 'Uzbekistan';
    541:
      Result := 'Vanuatu';
    734:
      Result := 'VenezuelaBolivarian Republic of';
    452:
      Result := 'Viet Nam';
    421:
      Result := 'Yemen';
    645:
      Result := 'Zambia';
    648:
      Result := 'Zimbabwe';
  else
    Result := IntToStr(countrycode);
  end;
end;

function MMC_Loookup_Network(countrycode, networkcode: Integer): string;
begin
  Result := IntToStr(networkcode);

  if countrycode = 412 then // Afghanistan
  begin
    case networkcode of
      1:
        Result := 'AWCC';
      20:
        Result := 'Roshan';
      40:
        Result := 'Areeba Afghanistan';
      50:
        Result := 'Etisalat';
      80:
        Result := 'Afghan Telecom';
      88:
        Result := 'Afghan Telecom';
    end;
  end
  else if countrycode = 276 then // Albania
  begin
    case networkcode of
      1:
        Result := 'Albanian Mobile Communications (AMC)';
      2:
        Result := 'Vodafone Albania';
      3:
        Result := 'Eagle Mobile';
      4:
        Result := 'Mobile 4 AL';
    end;
  end
  else if countrycode = 603 then // Algeria
  begin
    case networkcode of
      1:
        Result := 'Algérie Telecom';
      2:
        Result := 'Orascom Telecom Algérie';
    end;
  end
  else if countrycode = 213 then // Andorra
  begin
    case networkcode of
      3:
        Result := 'Mobiland';
    end;
  end
  else if countrycode = 631 then // Angola
  begin
    case networkcode of
      2:
        Result := 'Unitel';
      4:
        Result := 'Movicel';
    end;
  end
  else if countrycode = 722 then // Argentina
  begin
    case networkcode of
      10:
        Result := 'Compañia de Radiocomunicaciones Moviles S.A.';
      20:
        Result := 'Nextel Argentina srl';
      70:
        Result := 'Telefónica Comunicaciones Personales S.A.';
      310:
        Result := 'CTI PCS S.A.';
      320:
        Result := 'Compañia de Telefonos del Interior Norte S.A.';
      330:
        Result := 'Compañia de Telefonos del Interior S.A.';
      341:
        Result := 'Telecom Personal S.A.';
    end;
  end
  else if countrycode = 505 then // Australia
  begin
    case networkcode of
      1:
        Result := 'Telstra Corporation Ltd.';
      2:
        Result := 'Optus Mobile Pty. Ltd.';
      3:
        Result := 'Vodafone Network Pty. Ltd.';
      5:
        Result := 'Department of Defence';
      6:
        Result := 'The Ozitel Network Pty. Ltd.';
      7:
        Result := 'Hutchison 3G Australia Pty. Ltd.';
      8:
        Result := 'One.Tel GSM 1800 Pty. Ltd.';
      9:
        Result := 'Airnet Commercial Australia Ltd.';
      10:
        Result := 'Norfolk Telecom';
      11:
        Result := 'Telstra Corporation Ltd.';
      12:
        Result := 'Hutchinson TelecommunicationsAustralia Pty. Ltd.';
      13:
        Result := 'RailCorp';
      14:
        Result := 'AAPT';
      15:
        Result := '3GIS Pty LtdTelstra & Hutchinson 3G';
      16:
        Result := 'Victorian Rail Track';
      17:
        Result := 'Vivid Wireless Pty Ltd.';
      18:
        Result := 'Pactel International Pty Ltd.';
      19:
        Result := 'Lycamobile Pty Ltd';
      20:
        Result := 'Ausgrid Corporation';
      21:
        Result := 'Queensland Rail Limited';
      22:
        Result := 'iiNet Ltd';
      23:
        Result := 'Challenge Networks Pty Ltd.';
    end;
  end
  else if countrycode = 302 then // Canada
  begin
    case networkcode of
      220:
        Result := 'Telus Mobility';
      221:
        Result := 'Telus Mobility';
      250:
        Result := 'ALO Mobile Inc';
      270:
        Result := 'Bragg Communications';
      290:
        Result := 'Airtel Wireless';
      320:
        Result := 'Dave Wireless';
      340:
        Result := 'Execulink';
      360:
        Result := 'Telus Mobility';
      370:
        Result := 'Microcell';
      380:
        Result := 'Dryden Mobility';
      390:
        Result := 'Dryden Mobility';
      490:
        Result := 'Globalive Wireless';
      500:
        Result := 'Videotron Ltd';
      510:
        Result := 'Videotron Ltd';
      530:
        Result := 'Keewatinook Okimacinac	';
      560:
        Result := 'Lynx Mobility';
      570:
        Result := 'Light Squared';
      590:
        Result := 'Quadro Communication	';
      610:
        Result := 'Bell Mobility';
      620:
        Result := 'Ice Wireless';
      630:
        Result := 'Aliant Mobility	';
      640:
        Result := 'Bell Mobility';
      656:
        Result := 'Tbay Mobility';
      660:
        Result := 'MTS Mobility';
      670:
        Result := 'CityTel Mobility';
      680:
        Result := 'Sask Tel Mobility';
      690:
        Result := 'Bell Mobility';
      710:
        Result := 'Globalstar';
      720:
        Result := 'Rogers Wireless';
      730:
        Result := 'TerreStar Solutions';
      740:
        Result := 'Shaw Telecom G.P.';
      760:
        Result := 'Public Mobile Inc';
      770:
        Result := 'Rural Com';
      780:
        Result := 'Sask Tel Mobility';
      860:
        Result := 'Telus Mobility';
      880:
        Result := 'Telus/Bell shared';
      940:
        Result := 'Wightman Telecom';
      990:
        Result := 'Test';
    end;
  end
  else if countrycode = 460 then // China
  begin
    case networkcode of
      0:
        Result := 'China Mobile';
      1:
        Result := 'China Unicom';
      3:
        Result := 'China Unicom CDMA';
      4:
        Result := 'China Satellite Global Star Network';
    end;
  end
  else if countrycode = 208 then // France
  begin
    case networkcode of
      1:
        Result := 'Orange France';
      2:
        Result := 'Orange France';
      3:
        Result := 'MobiquiThings';
      4:
        Result := 'Sisteer';
      5:
        Result := 'Globalstar Europe';
      6:
        Result := 'Globalstar Europe';
      7:
        Result := 'Globalstar Europe';
      9:
        Result := 'S.F.R.';
      11:
        Result := 'S.F.R.';
      13:
        Result := 'S.F.R.';
      14:
        Result := 'RFF';
      15:
        Result := 'free Mobile';
      20:
        Result := 'Bouygues Telecom';
      21:
        Result := 'Bouygues Telecom';
      22:
        Result := 'Transatel';
      23:
        Result := 'Omer Telecom Ltd';
      24:
        Result := 'MobiquiThings';
      25:
        Result := 'Lycamobile';
      26:
        Result := 'NRJ Mobile';
      27:
        Result := 'Afone';
      28:
        Result := 'Astrium';
      29:
        Result := 'Société International Mobile Communication';
      30:
        Result := 'Symacom';
      31:
        Result := 'Mundio Mobile';
      88:
        Result := 'Bouygues Telecom';
      89:
        Result := 'Omer Telecom Ltd';
      90:
        Result := 'Images & Réseaux';
      91:
        Result := 'Orange France';
    end;
  end
  else if countrycode = 262 then // Germany
  begin
    case networkcode of
      1:
        Result := 'Telekom Deutschland GmbH';
      2:
        Result := 'Vodafone D2 GmbH';
      3:
        Result := 'E-Plus Mobilfunk GmbH & Co. KG';
      4:
        Result := 'Vodafone D2 GmbH';
      5:
        Result := 'E-Plus Mobilfunk GmbH & Co. KG';
      6:
        Result := 'Telekom Deutschland GmbH';
      7:
        Result := 'Telefonica Germany GmbH & Co. oHG';
      8:
        Result := 'Telefonica Germany GmbH & Co. oHG';
      9:
        Result := 'Vodafone D2 GmbH';
      10:
        Result := 'DB Netz AG';
      12:
        Result := 'E-Plus Mobilfunk GmbH & Co. KG';
      13:
        Result := 'Mobilcom Multimedia GmbH';
      14:
        Result := 'Quam GmbH';
      15:
        Result := 'AirData AG';
      16:
        Result := 'E-Plus Mobilfunk GmbH & Co. KG';
      17:
        Result := 'E-Plus Mobilfunk GmbH & Co. KG';
      18:
        Result := 'NetCologne Gesellschaft für Telekommunikation mbH';
      19:
        Result := 'Inquam Deutschland GmbH';
      20:
        Result := 'E-Plus Mobilfunk GmbH & Co. KG';
      41:
        Result := 'First Telecom GmbH';
      42:
        Result := 'Vodafone D2 GmbH';
      43:
        Result := 'Vodafone D2 GmbH';
      77:
        Result := 'E-Plus Mobilfunk GmbH & Co. KG';
      78:
        Result := 'Telekom Deutschland GmbH';
      79:
        Result := 'ng4T GmbH';
    end;
  end
  else if countrycode = 454 then // Hong Kong
  begin
    case networkcode of
      0:
        Result := 'CSL Limited';
      1:
        Result := 'CITIC Telecom 1616';
      2:
        Result := 'CSL Limited';
      3:
        Result := 'Hutchison Telecom';
      4:
        Result := 'Hutchison Telecom';
      5:
        Result := 'Hutchison Telecom';
      6:
        Result := 'SmarTone Mobile Communications Limited';
      7:
        Result := 'China UnicomHong Kong Limited';
      8:
        Result := 'Trident Telecom';
      9:
        Result := 'China Motion Telecom';
      10:
        Result := 'CSL Limited';
      11:
        Result := 'China-Hong Kong Telecom';
      12:
        Result := 'China Mobile Hong Kong Company Limited';
      14:
        Result := 'Hutchison Telecom';
      15:
        Result := '3G Radio System/SMT3G';
      16:
        Result := 'GSM1800/Mandarin Communications Ltd.';
      17:
        Result := 'SmarTone Mobile Communications Limited';
      18:
        Result := 'GSM7800/Hong Kong CSL Ltd.';
      19:
        Result := '3G Radio System/Sunday3G';
      29:
        Result := 'PCCW Limited';
      40:
        Result := 'shared by private TETRA systems';
      47:
        Result := 'Hong Kong Police Force – TETRA systems';
    end;
  end
  else if countrycode = 404 then // India
  begin
    case networkcode of
      0:
        Result := 'Dishnet Wireless Ltd, Madhya Pradesh';
      1:
        Result := 'Aircell Digilink India Ltd., Haryana';
      2:
        Result := 'Bharti Airtel Ltd., Punjab';
      3:
        Result := 'Bharti Airtel Ltd., H.P.';
      4:
        Result := 'Idea Cellular Ltd., Delhi';
      5:
        Result := 'Fascel Ltd., Gujarat';
      6:
        Result := 'Bharti Airtel Ltd., Karnataka';
      7:
        Result := 'Idea Cellular Ltd., Andhra Pradesh';
      9:
        Result := 'Reliance Telecom Ltd., Assam';
      10:
        Result := 'Bharti Airtel Ltd., Delhi';
      11:
        Result := 'Hutchison Essar Mobile Services Ltd, Delhi';
      12:
        Result := 'Idea Mobile Communications Ltd., Haryana';
      13:
        Result := 'Hutchison Essar South Ltd., Andhra Pradesh';
      14:
        Result := 'Spice Communications PVT Ltd., Punjab';
      15:
        Result := 'Aircell Digilink India Ltd., UP (East)';
      16:
        Result := 'Bharti Airtel Ltd, North East';
      17:
        Result := 'Dishnet Wireless Ltd, West Bengal';
      18:
        Result := 'Reliance Telecom Ltd., H.P.';
      19:
        Result := 'Idea Mobile Communications Ltd., Kerala';
      20:
        Result := 'Hutchison Essar Ltd, Mumbai';
      21:
        Result := 'BPL Mobile Communications Ltd., Mumbai';
      22:
        Result := 'Idea Cellular Ltd., Maharashtra';
      23:
        Result := 'Idea Cellular Ltd, Maharashtra';
      24:
        Result := 'Idea Cellular Ltd., Gujarat';
      25:
        Result := 'Dishnet Wireless Ltd, Bihar';
      27:
        Result := 'Hutchison Essar Cellular Ltd., Maharashtra';
      29:
        Result := 'Dishnet Wireless Ltd, Assam';
      30:
        Result := 'Hutchison Telecom East Ltd, Kolkata';
      31:
        Result := 'Bharti Airtel Ltd., Kolkata';
      33:
        Result := 'Dishnet Wireless Ltd, North East';
      34:
        Result := 'BSNL, Haryana';
      35:
        Result := 'Dishnet Wireless Ltd, Himachal Pradesh';
      36:
        Result := 'Reliance Telecom Ltd., Bihar';
      37:
        Result := 'Dishnet Wireless Ltd, J&K';
      38:
        Result := 'BSNL, Assam';
      40:
        Result := 'Bharti Airtel Ltd., Chennai';
      41:
        Result := 'Aircell Cellular Ltd, Chennai';
      42:
        Result := 'Aircel Ltd., Tamil Nadu';
      43:
        Result := 'Hutchison Essar Cellular Ltd., Tamil Nadu';
      44:
        Result := 'Spice Communications PVT Ltd., Karnataka';
      46:
        Result := 'Hutchison Essar Cellular Ltd., Kerala';
      48:
        Result := 'Dishnet Wireless Ltd, UP (West)';
      49:
        Result := 'Bharti Airtel Ltd., Andra Pradesh';
      50:
        Result := 'Reliance Telecom Ltd., North East';
      // India is incomplete...
    end;
  end
  else if countrycode = 510 then // Indonesia
  begin
    case networkcode of
      0:
        Result := 'PSN';
      1:
        Result := 'Satelindo';
      8:
        Result := 'Natrindo (Lippo Telecom)';
      10:
        Result := 'Telkomsel';
      11:
        Result := 'Excelcomindo';
      21:
        Result := 'Indosat - M3';
      28:
        Result := 'Komselindo';
    end;
  end
  else if countrycode = 418 then // Iraq
  begin
    case networkcode of
      5:
        Result := 'Asia Cell';
      20:
        Result := 'Zain Iraq (previously Atheer)';
      30:
        Result := 'Zain Iraq (previously Iraqna)';
      40:
        Result := 'Korek Telecom';
      47:
        Result := 'Iraq Central Cooperative Association for Communication and Transportation';
      48:
        Result := 'ITC Fanoos';
      49:
        Result := 'Iraqtel';
      62:
        Result := 'Itisaluna';
      70:
        Result := 'Kalimat';
      80:
        Result := 'Iraqi Telecommunications & Post Company (ITPC)';
      81:
        Result := 'ITPC (Al-Mazaya)';
      83:
        Result := 'ITPC (Sader Al-Iraq)';
      84:
        Result := 'ITPC (Eaamar Albasrah)';
      85:
        Result := 'ITPC (Anwar Yagotat Alkhalee)';
      86:
        Result := 'ITPC (Furatfone)';
      87:
        Result := 'ITPC (Al-Seraj)';
      88:
        Result := 'ITPC (High Link)';
      89:
        Result := 'ITPC (Al-Shams)';
      91:
        Result := 'ITPC (Belad Babel)';
      92:
        Result := 'ITPC (Al Nakheel)';
      93:
        Result := 'ITPC (Iraqcell)';
      94:
        Result := 'ITPC (Shaly)';
    end;
  end
  else if countrycode = 334 then // Mexico
  begin
    case networkcode of
      20:
        Result := 'TelCel';
    else
      Result := Result;
    end;
  end
  else if countrycode = 530 then // New Zealand
  begin
    case networkcode of
      1:
        Result := 'Vodafone New Zealand GSM Network';
      2:
        Result := 'Teleom New Zealand CDMA Network';
      3:
        Result := 'Woosh Wireless - CDMA Network';
      4:
        Result := 'TelstraClear - GSM Network';
      5:
        Result := 'Telecom New Zealand - UMTS Ntework';
      24:
        Result := 'NZ Communications - UMTS Network';
    end;
  end
  else if countrycode = 422 then // Oman
  begin
    case networkcode of
      2:
        Result := 'Oman Mobile Telecommunications Company (Oman Mobile)';
      3:
        Result := 'Oman Qatari Telecommunications Company (Nawras)';
      4:
        Result := 'Oman Telecommunications Company (Omantel)';
    end;
  end
  else if countrycode = 525 then // Singapore
  begin
    case networkcode of
      1:
        Result := 'SingTel ST GSM900';
      2:
        Result := 'SingTel ST GSM1800';
      3:
        Result := 'MobileOne';
      5:
        Result := 'Starhub';
      12:
        Result := 'Digital Trunked Radio Network';
    end;
  end
  else if countrycode = 655 then // South Africa
  begin
    case networkcode of
      1:
        Result := 'VodacomPty Ltd.';
      2:
        Result := 'Telkom SA Ltd';
      6:
        Result := 'SentechPty Ltd.';
      7:
        Result := 'Cell CPty Ltd.';
      10:
        Result := 'Mobile Telephone NetworksMTN Pty Ltd';
      11:
        Result := 'SAPS Gauteng';
      12:
        Result := 'Mobile Telephone NetworksMTN Pty Ltd';
      13:
        Result := 'Neotel Pty Ltd';
      21:
        Result := 'Cape Town Metropolitan Council';
      30:
        Result := 'Bokamoso Consortium Pty Ltd   ';
      31:
        Result := 'Karabo TelecomsPty Ltd.   ';
      32:
        Result := 'Ilizwi Telecommunications Pty Ltd   ';
      33:
        Result := 'Thinta Thinta Telecommunications Pty Ltd';
      34:
        Result := 'Bokone Telecoms Pty Ltd';
      35:
        Result := 'Kingdom Communications Pty Ltd';
      36:
        Result := 'Amatole Telecommunication Pty Ltd';
    end;
  end
  else if countrycode = 250 then // Russian Federation
  begin
    case networkcode of
      1:
        Result := 'Mobile Telesystems';
      2:
        Result := 'Megafon';
      3:
        Result := 'Nizhegorodskaya Cellular Communications';
      4:
        Result := 'Sibchallenge';
      5:
        Result := 'Mobile Comms System';
      7:
        Result := 'BM Telecom';
      10:
        Result := 'Don Telecom';
      11:
        Result := 'Orensot';
      12:
        Result := 'Baykal Westcom';
      13:
        Result := 'Kuban GSM';
      16:
        Result := 'New Telephone Company';
      17:
        Result := 'Ermak RMS';
      19:
        Result := 'Volgograd Mobile';
      20:
        Result := 'ECC';
      28:
        Result := 'Extel';
      39:
        Result := 'Uralsvyazinform';
      44:
        Result := 'Stuvtelesot';
      92:
        Result := 'Printelefone';
      93:
        Result := 'Telecom XXI';
      99:
        Result := 'Beeline';
    end;
  end
  else if countrycode = 214 then // Spain
  begin
    case networkcode of
      1:
        Result := 'Vodafone España, SAU';
      3:
        Result := 'France Telecom España, SA';
      4:
        Result := 'Xfera Móviles, S.A.';
      5:
        Result := 'Telefónica Móviles España, SAU';
      6:
        Result := 'Vodafone España, SAU';
      7:
        Result := 'Telefónica Móviles España, SAU';
      8:
        Result := 'Euskaltel, SA';
      9:
        Result := 'France Telecom España, SA';
      10:
        Result := 'Operadora de Telecomunicaciones Opera SL';
      11:
        Result := 'France Telecom España, SA';
      12:
        Result := 'Contacta Servicios Avanzados de Telecomunicaciones SL';
      13:
        Result := 'Incotel Ingeniera y Consultaria SL';
      14:
        Result := 'Incotel Servicioz Avanzados SL';
      15:
        Result := 'BT España Compañia de Servicios Globales de Telecomunicaciones, SAU';
      16:
        Result := 'Telecable de Asturias, SAU';
      17:
        Result := 'R Cable y Telecomunicaciones Galicia, SA';
      18:
        Result := 'Cableuropa, SAU';
      19:
        Result := 'E-Plus Móviles, SL';
      20:
        Result := 'Fonyou Telecom, SL';
      21:
        Result := 'Jazz Telecom, SAU';
      22:
        Result := 'Best Spain Telecom, SL';
      24:
        Result := 'Vizzavi España, S.L.';
      25:
        Result := 'Lycamobile, SL';
      26:
        Result := 'Lleida Networks Serveis Telemátics, SL';
      27:
        Result := 'SCN Truphone SL';
      28:
        Result := 'Consorcio de Telecomunicaciones Avanzadas, S.A.';
      29:
        Result := 'NEO-SKY 2002, S.A.';
      30:
        Result := 'Compatel Limited';
      31:
        Result := 'Red Digital De Telecomunicaciones de las Islas Baleares, S.L.';
    end;
  end
  else if countrycode = 228 then // Switzerland
  begin
    case networkcode of
      1:
        Result := 'Swisscom Schweiz AG';
      2:
        Result := 'Sunrise Communications AG';
      3:
        Result := 'Orange Communications SA';
      5:
        Result := 'Comfone AG';
      6:
        Result := 'SBB AG';
      8:
        Result := 'Tele2 Telecommunications AG';
      12:
        Result := 'Sunrise Communications AG';
      51:
        Result := 'Bebbicell AG';
    end;
  end
  else if countrycode = 286 then // Turkey
  begin
    case networkcode of
      1:
        Result := 'Turkcell';
      2:
        Result := 'Telsim GSM';
      3:
        Result := 'Aria';
      4:
        Result := 'Aycell';
    end;
  end
  else if countrycode = 234 then // United Kingdom
  begin
    case networkcode of
      0:
        Result := 'British Telecom';
      1:
        Result := 'Mapesbury Communications Ltd.';
      2:
        Result := 'O2 UK Ltd.';
      3:
        Result := 'Jersey Airtel Ltd';
      4:
        Result := 'FMS Solutions Ltd';
      5:
        Result := 'Colt Mobile Telecommunications Ltd';
      6:
        Result := 'Internet Computer Bureau Ltd';
      7:
        Result := 'Cable and Wireless UK';
      8:
        Result := 'OnePhoneUK Ltd';
      9:
        Result := 'Tismi BV';
      10:
        Result := 'O2 UK Ltd.';
      11:
        Result := 'O2 UK Ltd.';
      12:
        Result := 'Ntework Rail Infrastructure Ltd';
      13:
        Result := 'Ntework Rail Infrastructure Ltd';
      14:
        Result := 'Hay Systems Ltd';
      15:
        Result := 'Vodafone Ltd.';
      16:
        Result := 'Opal Telecom Ltd';
      17:
        Result := 'Flextel Ltd';
      18:
        Result := 'Cloud9';
      19:
        Result := 'Teleware plc';
      20:
        Result := 'Hutchison 3G UK Ltd.';
      21:
        Result := 'LogicStar Ltd';
      22:
        Result := 'Routo Telecommunications Ltd';
      23:
        Result := 'Vectone Network Ltd';
      24:
        Result := 'Stour Marine Ltd';
      25:
        Result := 'Software Cellular Network Ltd';
      26:
        Result := 'Lycamobile UK Ltd';
      27:
        Result := 'Teleena UK Ltd';
      28:
        Result := 'Marathon Telecom Ltd';
      29:
        Result := '(aq Limited T/A aql';
      30:
        Result := 'T-Mobile UK';
      31:
        Result := 'T-Mobile UK';
      32:
        Result := 'T-Mobile UK';
      33:
        Result := 'Orange';
      34:
        Result := 'Orange';
      50:
        Result := 'Jersey Telecom';
      55:
        Result := 'Cable and Wireless Guensey Ltd';
      58:
        Result := 'Manx Telecom';
      76:
        Result := 'British Telecom ';
      78:
        Result := 'Airwave mmO2 Ltd';
    end;
  end
  else if countrycode = 310 then // USA
  begin
    case networkcode of
      10:
        Result := 'Verizon Wireless';
      12:
        Result := 'Verizon Wireless';
      13:
        Result := 'Verizon Wireless';
      16:
        Result := 'Cricket Communications';
      17:
        Result := 'North Sight Communications Inc';
      20:
        Result := 'Union Telephone Company';
      30:
        Result := 'Centennial Communications';
      35:
        Result := 'ETEX Communications dba ETEX Wireless';
      40:
        Result := 'MTA Communications dba MTA Wireless';
      50:
        Result := 'Alaska Communications';
      60:
        Result := 'Consolidated Telcom';
      70:
        Result := 'Cingular Wireless';
      80:
        Result := 'Corr Wireless Communications LLC';
      90:
        Result := 'Criket Communications LLC';
      100:
        Result := 'New Mexico RSA 4 East Ltd. Partnership';
      110:
        Result := 'Pacific Telecom Inc';
      120:
        Result := 'Sprintcom Inc';
      130:
        Result := 'Carolina West Wireless';
      140:
        Result := 'GTA Wireless LLC';
      150:
        Result := 'Cingular Wireless';
      160:
        Result := 'T-Mobile USA';
      170:
        Result := 'Cingular Wireless';
      180:
        Result := 'West Central Wireless';
      190:
        Result := 'Alaska Wireless Communications LLC';
      200:
        Result := 'T-Mobile USA';
      210:
        Result := 'T-Mobile USA';
      220:
        Result := 'T-Mobile USA';
      230:
        Result := 'T-Mobile USA';
      240:
        Result := 'T-Mobile USA';
      250:
        Result := 'T-Mobile USA';
      260:
        Result := 'T-Mobile USA';
      270:
        Result := 'T-Mobile USA';
      280:
        Result := 'Contennial Puerto Rio License Corp.';
      290:
        Result := 'Nep Cellcorp Inc.';
      300:
        Result := 'Blanca Telephone Company';
      310:
        Result := 'T-Mobile USA';
      320:
        Result := 'Smith Bagley Inc, dba Cellular One';
      330:
        Result := 'AWCC';
      340:
        Result := 'High Plains Midwest LLC, dba Wetlink Communications';
      350:
        Result := 'Mohave Cellular L.P.';
      360:
        Result := 'Cellular Network Partnership dba Pioneer Cellular';
      370:
        Result := 'Guamcell Cellular and Paging';
      380:
        Result := 'New Cingular Wireless PCS, LLC';
      390:
        Result := 'TX-11 Acquistion LLC';
      400:
        Result := 'Wave Runner LLC';
      410:
        Result := 'Cingular Wireless';
      420:
        Result := 'Cincinnati Bell Wireless LLC';
      430:
        Result := 'Alaska Digitel LLC';
      440:
        Result := 'Numerex Corp';
      450:
        Result := 'North East Cellular Inc.';
      460:
        Result := 'TMP Corporation';
      470:
        Result := 'nTELOS Communications IncVirginia PCS Alliance LC';
      480:
        Result := 'Choice Phone LLC';
      490:
        Result := 'T-Mobile USA';
      500:
        Result := 'Public Service Cellular, Inc.';
      510:
        Result := 'Nsighttel Wireless LLC';
      520:
        Result := 'Transactions Network Services';
      530:
        Result := 'Iowa Wireless Services LLC';
      540:
        Result := 'Oklahoma Western Telephone Company';
      550:
        Result := 'Wireless Solutions International';
      560:
        Result := 'Cingular Wireless';
      570:
        Result := 'MTPCS LLC';
      580:
        Result := 'Inland Cellular Telephone Company';
      590:
        Result := 'Verizon Wireless';
      600:
        Result := 'New Cell Inc. dba Cellcom';
      610:
        Result := 'Elkhart Telephone Co. Inc. dba Epic Touch Co.';
      620:
        Result := 'Nsighttel Wireless LLC';
      630:
        Result := 'Agri-Valley Broadband Inc';
      640:
        Result := 'Airadigm Communications';
      650:
        Result := 'Jasper Wireless Inc.';
      660:
        Result := 'T-Mobile USA';
      670:
        Result := 'AT&T Mobility Vanguard Services';
      680:
        Result := 'Cingular Wireless';
      690:
        Result := 'Keystane Wireless LLC';
      700:
        Result := 'Cross Valiant Cellular Partnership';
      710:
        Result := 'Arctic Slope Telephone Association Cooperative';
      720:
        Result := 'Wireless Solutions International Inc.';
      730:
        Result := 'US Cellular';
      740:
        Result := 'Convey Communications Inc';
      750:
        Result := 'East Kentucky Network LLC dba Appalachian Wireless';
      760:
        Result := 'Lynch 3G Communications Corporation';
      770:
        Result := 'Iowa Wireless Services LLC dba I Wireless';
      780:
        Result := 'Connect Net Inc';
      790:
        Result := 'PinPoint Communications Inc.';
      800:
        Result := 'T-Mobile USA';
      810:
        Result := 'LCFR LLC';
      820:
        Result := 'South Canaan Cellular Communications Co. LP';
      830:
        Result := 'Caprock Cellular Ltd. Partnership';
      840:
        Result := 'Telecom North America Mobile Inc';
      850:
        Result := 'Aeris Communications, Inc.';
      860:
        Result := 'TX RSA 15B2, LP dba Five Star Wireless';
      870:
        Result := 'Kaplan Telephone Company Inc.';
      880:
        Result := 'Advantage Cellular Systems, Inc.';
      890:
        Result := 'Rural Cellular Corporation';
      900:
        Result := 'Cable & Communications Corporation dba Mid-Rivers  Wireless';
      910:
        Result := 'Verizon Wireless';
      920:
        Result := 'James Valley Wireless LLC';
      930:
        Result := 'Copper Valley Wireless';
      940:
        Result := 'Iris Wireless LLC';
      950:
        Result := 'Texas RSA 1 dba XIT Wireless';
      960:
        Result := 'UBET Wireless';
      970:
        Result := 'Globalstar USA';
      980:
        Result := 'Texas RSA 7B3 dba Peoples Wireless Services';
      990:
        Result := 'Worldcall Interconnect';
    end;
  end;

  if Result = '' then
    Result := IntToStr(networkcode);
end;

begin

end.
