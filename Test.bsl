&НаКлиентеНаСервереБезКонтекста
&Вместо("ПолучитьТекстПодсказкиДляДокументаМК")
Функция MFOSE_1842_ПолучитьТекстПодсказкиДляДокументаМК(СтраныМК, Гражданство, ДатаВыдачи, СрокДействия, ДатаДоговора)
	
	ТекстПодсказкиДатаВыдачи = "";
	
	Если Не СтраныМК = Неопределено И СтраныМК.Свойство("СписокСтран_МК_01022014") 
		и Не СтраныМК.СписокСтран_МК_01022014.Найти(Гражданство) = Неопределено 
		и ЗначениеЗаполнено(ДатаВыдачи)
		и ДатаВыдачи < Дата(2014,2,1)
		//Вашкявичус ДР 2022-09-09 {
		//MFOSE-839 доработка условия по комментарию к задаче
		//} Вашкявичус ДР 2022-09-09
		//Вашкявичус ДР 2022-08-30 {
		//MFOSE-839 доработка условия по комментарию к задаче
		и СрокДействия <= ДатаДоговора Тогда
		//} Вашкявичус ДР 2022-08-30
		ТекстПодсказкиДатаВыдачи = "Запросить ВНЖ";  
	КонецЕсли;
	
	Если Не СтраныМК = Неопределено И СтраныМК.Свойство("СписокСтран_МК_01042018")
		и Не СтраныМК.СписокСтран_МК_01042018.Найти(Гражданство) = Неопределено 
		и ДатаВыдачи < Дата(2018,4,1)
		//Вашкявичус ДР 2022-09-09 {
		//MFOSE-839 доработка условия по комментарию к задаче
		и ЗначениеЗаполнено(ДатаВыдачи)
		//} Вашкявичус ДР 2022-09-09
		//Вашкявичус ДР 2022-08-30 {
		//MFOSE-839 доработка условия по комментарию к задаче
		и СрокДействия <= ДатаДоговора	Тогда
		//} Вашкявичус ДР 2022-08-30
		ТекстПодсказкиДатаВыдачи = "Запросить ВНЖ";
	КонецЕсли;	
	
	Возврат ТекстПодсказкиДатаВыдачи;

КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьНеПодсвечивать(СтраныМК, Гражданство, ДатаВыдачи, СрокДействия, ДатаДоговора) 
	
	НеПодсвечивать = Ложь;
	
	Если Не СтраныМК = Неопределено И СтраныМК.Свойство("СписокСтран_МК_01022014") 
		и Не СтраныМК.СписокСтран_МК_01022014.Найти(Гражданство) = Неопределено
		и ДатаВыдачи < Дата(2014,2,1)
		и ЗначениеЗаполнено(ДатаВыдачи) Тогда 
		НеПодсвечивать = Истина;  
	КонецЕсли;
	
	Если Не СтраныМК = Неопределено И СтраныМК.Свойство("СписокСтран_МК_01042018")
		и Не СтраныМК.СписокСтран_МК_01042018.Найти(Гражданство) = Неопределено 
		и ДатаВыдачи < Дата(2018,4,1)
		и ЗначениеЗаполнено(ДатаВыдачи) Тогда
		НеПодсвечивать = Истина;
	КонецЕсли;	
	
	Возврат НеПодсвечивать;
	
КонецФункции // ПолучитьТекстПодсказкиДляДокументаМК()
  
&НаСервере
&Вместо("ЗаполнитьТекстыПодсказокПоВидамДокументов")
Процедура MFOSE_1842_ЗаполнитьТекстыПодсказокПоВидамДокументов()

	//Переменные
	СтраныМК = Новый Структура;
	СписокСтран_МК_01022014 = ЦФТ_ПовтИсп.Страны_ВыдачаМК_НеРанее01022014();
	СписокСтран_МК_01042018 = ЦФТ_ПовтИсп.Страны_ВыдачаМК_НеРанее01042018();
	
	//будем хранить для дальнейшего пересчета на клиенте
	СтраныМК.Вставить("СписокСтран_МК_01022014",СписокСтран_МК_01022014);
	СтраныМК.Вставить("СписокСтран_МК_01042018",СписокСтран_МК_01042018);
	
	ВидДокументаМК   = ЦФТ_ОбщегоНазначенияСервер.ВидДокументаМК();
	ВидДокументаВНЖ  = ЦФТ_ОбщегоНазначенияСервер.ВидДокументаВНЖ();
	ВидДокументаВиза = ЦФТ_ОбщегоНазначенияСервер.ВидДокументаВиза();

	ДатаРождения = Объект.ДатаРождения;
	Гражданство  = Объект.Гражданство;
	
	ТаблицаПодсказок.Очистить();
	
	//Рассчет по каждой строке документы:
	Для Каждого СтрокаДокумент Из Объект.ДокументыФизическихЛиц Цикл
		
		ТекстПодсказкиДатаВыдачи   = "";
		ТекстПодсказкиСрокДействия = ""; 
		
		СтрокаПодсказки = ТаблицаПодсказок.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаПодсказки, СтрокаДокумент);
		
		// Бирюков Максим 23.12.22 {
		//Заполним параметры для повторных пересчетов на клиенте:
		СтрокаПодсказки.МК       = СтрокаДокумент.ВидДокумента = ВидДокументаМК;
		СтрокаПодсказки.ВНЖ      = СтрокаДокумент.ВидДокумента = ВидДокументаВНЖ;
		СтрокаПодсказки.Виза     = СтрокаДокумент.ВидДокумента = ВидДокументаВиза;
		СтрокаПодсказки.СтраныМК = СтраныМК;
		// } Бирюков Максим 23.12.22 
		
		СтрокаПодсказки.НеПодсвечивать = ?(СтрокаПодсказки.МК, Истина, Ложь);
		
		Если СтрокаДокумент.ВидДокумента = ВидДокументаМК Тогда
			ТекстПодсказкиДатаВыдачи = ПолучитьТекстПодсказкиДляДокументаМК(СтраныМК, Гражданство, СтрокаДокумент.ДатаВыдачи, СтрокаДокумент.СрокДействия, ДатаДоговора);
			СтрокаПодсказки.НеПодсвечивать = ПолучитьНеПодсвечивать(СтраныМК, Гражданство, СтрокаДокумент.ДатаВыдачи, СтрокаДокумент.СрокДействия, ДатаДоговора);
		КонецЕсли; 
		
		Если СтрокаДокумент.ВидДокумента = ВидДокументаВНЖ Тогда
			ТекстПодсказкиСрокДействия = ПолучитьТекстПодсказкиДляДокументаВНЖ(СтрокаДокумент.ДатаВыдачи, СтрокаДокумент.СрокДействия, ДатаРождения, ДатаДоговора);
		КонецЕсли;
		
		Если СтрокаДокумент.ВидДокумента = ВидДокументаВиза Тогда
			ТекстПодсказкиСрокДействия = ПолучитьТекстПодсказкиДляДокументаВиза(СтрокаДокумент.ДатаВыдачи, СтрокаДокумент.СрокДействия, ДатаДоговора);
		КонецЕсли;
		
		Если СтрокаДокумент.ВидДокумента = Справочники.ВидыДокументовФизическихЛиц.ПаспортРФ 
			И ДокументРФНедействителенПоВозрасту(ДатаРождения, СтрокаДокумент.ДатаВыдачи, ДатаДоговора, ПрименятьСрокЗаменыПаспортаРФ) Тогда
			ТекстПодсказкиСрокДействия = "Недействителен по возрасту";
		КонецЕсли;
		
		СтрокаПодсказки.ТекстПодсказкиДатаВыдачи   = ТекстПодсказкиДатаВыдачи;
		СтрокаПодсказки.ТекстПодсказкиСрокДействия = ТекстПодсказкиСрокДействия;
		// } Бирюков Максим 13.12.22 
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
&Вместо("ОбновитьНадписиПодсказок")
Процедура MFOSE_1842_ОбновитьНадписиПодсказок(ТекДаные)

	// Бирюков Максим 16.12.22 {
	// Заранее формируем таблицу подсказок - здесь из таблицы подсказок без расчетов
	// получаем сразу текст подсказки
	Если ТекДаные = Неопределено тогда
		Возврат;
	КонецЕсли;
	//СтруктураПодсказок = ПолучитьПодсказки(Объект.Гражданство,ТекДаные.ВидДокумента, ТекДаные.ДатаВыдачи, ТекДаные.СрокДействия, Объект.Займ);	
	//Элементы.ГруппаДатаВыдачиИСрокДействия_НадписьДатаВыдачи.Заголовок = СтруктураПодсказок.ТекстПодсказкиДатаВыдачи;
	//Элементы.ГруппаДатаВыдачиИСрокДействия_НадписьСрокДействия.Заголовок = СтруктураПодсказок.ТекстПодсказкиСрокДействия;
	//Если ЗапущенаПроверка и ЗначениеЗаполнено(СтруктураПодсказок.ТекстПодсказкиДатаВыдачи) Тогда
	//	Элементы.ДатаВыдачи.ЦветФона = WebЦвета.Красный;
	//Иначе
	//	Элементы.ДатаВыдачи.ЦветФона = WebЦвета.Белый;
	//КонецЕсли;
	//
	//Если ЗапущенаПроверка и ЗначениеЗаполнено(СтруктураПодсказок.ТекстПодсказкиСрокДействия) Тогда
	//	Элементы.СрокДействия.ЦветФона = WebЦвета.Красный;
	//Иначе
	//	Элементы.СрокДействия.ЦветФона = WebЦвета.Белый;
	//КонецЕсли; 

	//По-умолчанию:
	Элементы.ГруппаДатаВыдачиИСрокДействия_НадписьДатаВыдачи.Заголовок = "";
	Элементы.ГруппаДатаВыдачиИСрокДействия_НадписьСрокДействия.Заголовок = "";
	Элементы.ДатаВыдачи.ЦветФона = WebЦвета.Белый;
	Элементы.СрокДействия.ЦветФона = WebЦвета.Белый;

	//Проверим подсказки и добавим оформление
	Отбор = Новый Структура("ВидДокумента, Период, ИдДокумента", ТекДаные.ВидДокумента, ТекДаные.Период, ТекДаные.ИдДокумента);
	СтрокиПодсказки = ТаблицаПодсказок.НайтиСтроки(Отбор);
	Для Каждого СтрокаПодсказки Из СтрокиПодсказки Цикл
			
			// Подсказка дата выдачи
			Если ЗначениеЗаполнено(СтрокаПодсказки.ТекстПодсказкиДатаВыдачи) Тогда
				Элементы.ГруппаДатаВыдачиИСрокДействия_НадписьДатаВыдачи.Заголовок = СтрокаПодсказки.ТекстПодсказкиДатаВыдачи;
				Если ЗапущенаПроверка и не СтрокаПодсказки.НеПодсвечивать Тогда
					Элементы.ДатаВыдачи.ЦветФона = WebЦвета.Красный;
				КонецЕсли;
			КонецЕсли;	
			
			// Подсказка срок действия
			Если ЗначениеЗаполнено(СтрокаПодсказки.ТекстПодсказкиСрокДействия) Тогда
				Элементы.ГруппаДатаВыдачиИСрокДействия_НадписьСрокДействия.Заголовок = СтрокаПодсказки.ТекстПодсказкиСрокДействия;
				Если ЗапущенаПроверка и не СтрокаПодсказки.НеПодсвечивать Тогда
					Элементы.СрокДействия.ЦветФона = WebЦвета.Красный;
				КонецЕсли;
			КонецЕсли;
		
	КонецЦикла;
	// } Бирюков Максим 16.12.22 

КонецПроцедуры

&НаКлиенте
&Вместо("ПересчитатьПараметрыПодсказокДляДокумента")
Процедура MFOSE_1842_ПересчитатьПараметрыПодсказокДляДокумента(ТекДанные)

	// Бирюков Максим 2023-04-10 {
	// Может появлятся значение "Неопределено"
	Если ТекДанные = Неопределено Тогда
		Возврат;	
	КонецЕсли;
	// } Бирюков Максим 2023-04-10

	//В данной процедуры постараемся по-максимуму пересчитать все на клиенте
	//все что возможно пересчитать на клиенте:
	ДатаРождения = Объект.ДатаРождения;
	Гражданство	 = Объект.Гражданство;

	ТекстПодсказкиДатаВыдачи   = "";
	ТекстПодсказкиСрокДействия = "";

	Отбор = Новый Структура("ВидДокумента, Период, ИдДокумента", ТекДанные.ВидДокумента, ТекДанные.Период, ТекДанные.ИдДокумента);
	СтрокиПодсказки = ТаблицаПодсказок.НайтиСтроки(Отбор);
	Если СтрокиПодсказки.Количество()> 0 Тогда

		СтрокаПодсказки = СтрокиПодсказки[0];
		СтраныМК 		= СтрокаПодсказки.СтраныМК;

		Если СтрокаПодсказки.МК Тогда
			ТекстПодсказкиДатаВыдачи = ПолучитьТекстПодсказкиДляДокументаМК(СтраныМК, Гражданство, ТекДанные.ДатаВыдачи, ТекДанные.СрокДействия, ДатаДоговора);
			
			СтрокаПодсказки.НеПодсвечивать = ПолучитьНеПодсвечивать(СтраныМК, Гражданство, ТекДанные.ДатаВыдачи, ТекДанные.СрокДействия, ДатаДоговора);
			
		КонецЕсли;

		Если СтрокаПодсказки.ВНЖ Тогда
			ТекстПодсказкиСрокДействия = ПолучитьТекстПодсказкиДляДокументаВНЖ(ТекДанные.ДатаВыдачи, ТекДанные.СрокДействия, ДатаРождения, ДатаДоговора);
		КонецЕсли;

		Если СтрокаПодсказки.Виза Тогда
			ТекстПодсказкиСрокДействия = ПолучитьТекстПодсказкиДляДокументаВиза(ТекДанные.ДатаВыдачи, ТекДанные.СрокДействия, ДатаДоговора);
		КонецЕсли;

		Если СтрокаПодсказки.ВидДокумента = ПредопределенноеЗначение("Справочник.ВидыДокументовФизическихЛиц.ПаспортРФ") 
			И ДокументРФНедействителенПоВозрасту(ДатаРождения, ТекДанные.ДатаВыдачи, ДатаДоговора, ПрименятьСрокЗаменыПаспортаРФ) Тогда
			ТекстПодсказкиСрокДействия = "Недействителен по возрасту";
		КонецЕсли;

		СтрокаПодсказки.ТекстПодсказкиДатаВыдачи   = ТекстПодсказкиДатаВыдачи;
		СтрокаПодсказки.ТекстПодсказкиСрокДействия = ТекстПодсказкиСрокДействия;

	КонецЕсли;

КонецПроцедуры


