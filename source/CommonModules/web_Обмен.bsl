#Область JSON

Функция СформироватьJSON(ДанныеДляЗапроса) Экспорт
	Попытка
		ЗаписьJSON = Новый ЗаписьJSON;
		ЗаписьJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON(, Символы.Таб));
		
		НастройкаСериализацииJSON = Новый НастройкиСериализацииJSON;
		НастройкаСериализацииJSON.ВариантЗаписиДаты = ВариантЗаписиДатыJSON.ЛокальнаяДатаСоСмещением;
		НастройкаСериализацииJSON.ФорматСериализацииДаты = ФорматДатыJSON.ISO;
		
		ЗаписатьJSON(ЗаписьJSON, ДанныеДляЗапроса, НастройкаСериализацииJSON);
		
		Возврат ЗаписьJSON.Закрыть();
	Исключение
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
	КонецПопытки;
КонецФункции

Функция ПрочитатьСтрокуJSON(СтрокаJSON, ИменаСвойствСоЗначениямиДата = Неопределено) Экспорт
	Результат = Неопределено;
	
	Если НЕ ЗначениеЗаполнено(СтрокаJSON) Тогда
		Возврат Результат;
	КонецЕсли;
	
	Попытка
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(СтрокаJSON);
		Результат = ПрочитатьJSON(ЧтениеJSON, Истина, ИменаСвойствСоЗначениямиДата);
	Исключение
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
	КонецПопытки;
	
	Возврат Результат;
КонецФункции	

#КонецОбласти


#Область ФункцииОбмена

Функция СформироватьНастройкиСоединения()
	НастройкиСоединения = Новый Структура("Адрес,Порт,SSL", Неопределено, 80, Неопределено);
	
	НастройкиСоединения.Адрес =	web_ОбщегоНазначения.ПолучитьНастройку_АдресПортала();
	Порт = web_ОбщегоНазначения.ПолучитьНастройку_Порт();
	ЗащищенноеСоединение = web_ОбщегоНазначения.ПолучитьНастройку_ЗащищенноеСоединение();
	
	Если ЗначениеЗаполнено(Порт) Тогда
		НастройкиСоединения.Порт = ?(ТипЗнч(Порт) = Тип("Число"), Порт, Число(Порт));
	ИначеЕсли ЗащищенноеСоединение Тогда
		НастройкиСоединения.Порт = 443;
	КонецЕсли;
	
	Если ЗащищенноеСоединение Тогда
		НастройкиСоединения.SSL = Новый ЗащищенноеСоединениеOpenSSL;	
	КонецЕсли;
	
	Возврат НастройкиСоединения;
КонецФункции

Функция ПолучитьАдресРесурса(URL, СсылкаНаОбъект = Неопределено) Экспорт
	Если СсылкаНаОбъект = Неопределено Тогда
		Возврат СтрШаблон("backend/api/v1/%1/", URL);
	ИначеЕсли ТипЗнч(СсылкаНаОбъект) = Тип("Строка") Тогда
		Возврат СтрШаблон("backend/api/v1/%1/2%/", URL, СсылкаНаОбъект);
	Иначе
		Возврат СтрШаблон("backend/api/v1/%1/%2/", URL, XMLСтрока(СсылкаНаОбъект));
	КонецЕсли;
КонецФункции

Функция HEAD(АдресРесурса, СсылкаНаОбъект)
	Результат = ОтправитьHTTPЗапрос("HEAD", ПолучитьАдресРесурса(АдресРесурса, СсылкаНаОбъект));
	Возврат Результат.Код;
КонецФункции

Функция ОтчиститьУспешныйОбмен(УспешныйОбмен)
	Попытка
		Для Каждого Данные Из УспешныйОбмен Цикл
			НаборЗаписей = РегистрыСведений.web_СписокОбменаССайтом.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.СсылкаНаОбъект.Установить(Данные);
			НаборЗаписей.Записать();
		КонецЦикла;
	Исключение
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
	КонецПопытки;	
КонецФункции

Функция СформироватьОтвет(Данные) Экспорт
	ДанныеJSON = ПрочитатьСтрокуJSON(Данные.Тело);
	Возврат СтрШаблон("%1%2%3", Данные.Код, Символы.ВК + Символы.ПС, СформироватьJSON(ДанныеJSON));
КонецФункции

Функция ПолучитьТипИзображения(Расширение) 
	ТипКатринки = "image/jpeg";
	
	Если СтрЗаканчиваетсяНа(Расширение, "png") Тогда
		ТипКатринки = "image/png";
	ИначеЕсли СтрЗаканчиваетсяНа(Расширение, "gif") Тогда
		ТипКатринки = "image/gif";
	КонецЕсли;
	
	Возврат ТипКатринки;
КонецФункции

Функция ОбъектЕстьНаСайте(URL, СсылкаНаОбъект) Экспорт

	КодОтвета = HEAD(URL, СсылкаНаОбъект);
	Если КодОтвета = 200 Тогда
		Возврат Истина;	
	КонецЕсли;
	Возврат Ложь;
КонецФункции

Процедура MFD_ДобавитьИзображение(ЗаписьДанных, Разделитель, ИмяПараметра, ИмяФайла, ТипИзображения, ДвоичныеДанные) Экспорт   
	//
	//	Функция добавляет в контент запроса тело изображения
	//
	//	Параметры:
	//
	//		ЗаписьДанных -- (ЗаписьДанных) буфер запроса (контент)
	//
	//		Разделитель  -- (Строка) разделитель параметров в теле запроса
	//
	//		ИмяПараметра -- (Строка) имя параметра: image
	//
	//		ИмяФайла -- (Строка) имя файла изображения: Content-Disposition
	//
	//		ТипИзображения -- (Строка) тип файла изображения: Content-Type
	//
	//		ДвоичныеДанные -- (Двоичные данные) тело изображения
	//
	Если НЕ ИмяПараметра = "image" Тогда
		Возврат;
	КонецЕсли;
	
	web_ОбщегоНазначения.Трассировка("image: "+ИмяПараметра+" ["+ИмяФайла+"]"+ ", ТипИзображения: ["+ТипИзображения+"]" );
	
	ЗаписьДанных.ЗаписатьСтроку("--" + Разделитель);
	ЗаписьДанных.ЗаписатьСтроку(СтрШаблон(
		"Content-Disposition: form-data; name=""%1""; filename=""%2""",
		ИмяПараметра,
		ИмяФайла
	));
	ЗаписьДанных.ЗаписатьСтроку(СтрШаблон("Content-Type: %1", ТипИзображения));
	ЗаписьДанных.ЗаписатьСтроку("");

	Если ЗначениеЗаполнено(ДвоичныеДанные) Тогда
		ЗаписьДанных.Записать(ДвоичныеДанные);
		ЗаписьДанных.ЗаписатьСтроку(Символы.ВК + Символы.ПС);
		ЗаписьДанных.ЗаписатьСтроку("");
		//ЗаписьДанных.ЗаписатьСтроку("--");
	КонецЕсли;
КонецПроцедуры

Процедура MFD_ДобавитьПараметр(ЗаписьДанных, Разделитель, ИмяПараметра, ЗначениеПараметра) Экспорт   
	//
	//	Функция добавляет в контент запроса строковый параметр
	//
	//	Параметры:
	//
	//		ЗаписьДанных -- (ЗаписьДанных) буфер запроса (контент)
	//
	//		Разделитель  -- (Строка) разделитель параметров в теле запроса
	//
	//		ИмяПараметра -- (Строка) имя параметра
	//
	//		ЗначениеПараметра -- значение параметра
	//

	Если НЕ ЗначениеЗаполнено(ЗначениеПараметра) ИЛИ СокрП(ЗначениеПараметра) = "" Тогда
        Возврат
	КонецЕсли;
	
	web_ОбщегоНазначения.Трассировка("Параметр: "+ИмяПараметра+": ["+ЗначениеПараметра+"]" );

	ЗаписьДанных.ЗаписатьСтроку("--" + Разделитель);
	ЗаписьДанных.ЗаписатьСтроку(СтрШаблон("Content-Disposition: form-data; name=""%1""", ИмяПараметра));
	ЗаписьДанных.ЗаписатьСтроку("");
	ЗаписьДанных.ЗаписатьСтроку(ЗначениеПараметра);

	Если ИмяПараметра = "id" Тогда
		ImageID = ЗначениеПараметра;
	КонецЕсли;
КонецПроцедуры

Функция MFD_ЗаполнитьПараметр(
	ИмяПараметра      = Неопределено, 
	ЗначениеПараметра = Неопределено, 
	ИмяФайла          = Неопределено, 
	Расширение        = Неопределено,
	ДвоичныеДанные    = Неопределено
) Экспорт   
	//
	//
	//
	Параметр = Новый Структура;
	Параметр.Вставить("ИмяПараметра", ИмяПараметра);
	Параметр.Вставить("ЗначениеПараметра", ЗначениеПараметра);
	Параметр.Вставить("ИмяФайла", СтрШаблон("%1.%2", ИмяФайла, Расширение));
	Параметр.Вставить("Расширение", Расширение);
	Параметр.Вставить("ДвоичныеДанные", ДвоичныеДанные);
	
	Если ДвоичныеДанные = Неопределено тогда
		Параметр.Вставить("ЭтоИзображение", Ложь);
	Иначе	
	    Параметр.Вставить("ЭтоИзображение", Истина);
	КонецЕсли;
	
	Возврат Параметр;
КонецФункции

Функция ПолучитьОтправленныеОбъекты(СписокОбмена)
	Отправленные = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	web_ОтправленныеОбъекты.СсылкаНаОбъект КАК СсылкаНаОбъект
		|ИЗ
		|	РегистрСведений.web_ОтправленныеОбъекты КАК web_ОтправленныеОбъекты
		|ГДЕ
		|	web_ОтправленныеОбъекты.СсылкаНаОбъект В(&СписокСсылок)";
	
	Запрос.УстановитьПараметр("СписокСсылок", СписокОбмена);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Отправленные;
	КонецЕсли;
		
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Отправленные.Вставить(Выборка.СсылкаНаОбъект, Выборка.СсылкаНаОбъект);
	КонецЦикла;
	
	Возврат Отправленные;
КонецФункции

Процедура ДобавитьВОтправленныеОбъекты(УспешныйОбмен, Отправленные)
	Попытка
		Для Каждого Данные Из УспешныйОбмен Цикл
			Если НЕ Отправленные[Данные] = Неопределено Тогда
				Продолжить;	
			КонецЕсли;
			
			МенеджерЗаписи = РегистрыСведений.web_ОтправленныеОбъекты.СоздатьМенеджерЗаписи();
			МенеджерЗаписи.СсылкаНаОбъект = Данные;
			МенеджерЗаписи.Записать();
		КонецЦикла;
	Исключение
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());	
	КонецПопытки;
КонецПроцедуры

#КонецОбласти

#Область ОтправкаДанныхНаСайт

Функция ПолучитьСписокОбмена()
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	web_СписокОбменаССайтом.СсылкаНаОбъект КАК СсылкаНаОбъект,
		|	web_СписокОбменаССайтом.ПриоритетВыгрузки КАК ПриоритетВыгрузки
		|ИЗ
		|	РегистрСведений.web_СписокОбменаССайтом КАК web_СписокОбменаССайтом
		|
		|УПОРЯДОЧИТЬ ПО
		|	ПриоритетВыгрузки";
	
	РезультатЗапроса = Запрос.Выполнить();	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат РезультатЗапроса.Выгрузить();
КонецФункции

Функция ОтправитьНаСайт(СписокОбмена, УспешныйОбмен, Отправленные, ПолнаяВыгрузка)
	//
	//	
	//
	Для каждого ТекущийОбъект Из СписокОбмена Цикл
		Если НЕ ПолнаяВыгрузка И НЕ Отправленные[ТекущийОбъект.СсылкаНаОбъект] = Неопределено Тогда
			УспешныйОбмен.Добавить(ТекущийОбъект.СсылкаНаОбъект);
			Продолжить;
		КонецЕсли;
		web_ОбщегоНазначения.Трассировка("----------------------------------");
		Попытка
			Результат = web_ОбщегоНазначения.ОтправитьНаСайт(ТекущийОбъект.СсылкаНаОбъект, ПолнаяВыгрузка);
		Исключение
			ТекстОшибки = ОписаниеОшибки();
			Сообщить(ТекстОшибки);
			ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ТекстОшибки);
		КонецПопытки;
		
		Если НЕ Результат = Неопределено Тогда
			УспешныйОбмен.Добавить(Результат);
		КонецЕсли;
	КонецЦикла;
КонецФункции

Процедура ВыполнитьОбменССайтом(ПолнаяВыгрузка = Ложь) Экспорт
	//
	//	 Обмен с сайтом: Выгрузка Номенклатуры
	//	 Источник:
	//	 РегистрСведений.web_СписокОбменССайтом.ФормаСписка.МодульФормы
	//
	СписокОбмена = ПолучитьСписокОбмена();
	Если СписокОбмена = Неопределено Тогда
		Информация = "Нет объектов для выгрузки.";
		Сообщить(Информация);
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Информация,,, Информация); 
	КонецЕсли;
	
	Отправленные = ПолучитьОтправленныеОбъекты(СписокОбмена.ВыгрузитьКолонку("СсылкаНаОбъект"));
	
	УспешныйОбмен = Новый Массив;
	ОтправитьНаСайт(СписокОбмена, УспешныйОбмен, Отправленные, ПолнаяВыгрузка);
	ДобавитьВОтправленныеОбъекты(УспешныйОбмен, Отправленные);
	ОтчиститьУспешныйОбмен(УспешныйОбмен);
КонецПроцедуры

Процедура ВыполнитьОбменЦенамиССайтом(ПолнаяВыгрузка = Ложь) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
	    |	web_СписокОбменаЦенами.Номенклатура КАК Номенклатура,
	    |	web_СписокОбменаЦенами.Характеристика КАК Характеристика,
	    |	web_СписокОбменаЦенами.Цена КАК Цена
	    |ИЗ
	    |	РегистрСведений.web_СписокОбменаЦенами КАК web_СписокОбменаЦенами";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	УспешныйОбмен = Новый Соответствие;  
	
	Выборка = РезультатЗапроса.Выбрать();
	Попытка
		Пока Выборка.Следующий() Цикл
			Результат = web_Price.ОтправитьЦеныНаСайт(Выборка.Номенклатура, Выборка.Характеристика, Выборка.Цена);			
			Если НЕ Результат = Неопределено Тогда
				УспешныйОбмен.Вставить(Результат);	
			КонецЕсли;
		КонецЦикла;
	Исключение
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
	КонецПопытки;
	
	Попытка
		Для Каждого Данные Из УспешныйОбмен Цикл
			НаборЗаписей = РегистрыСведений.web_СписокОбменаЦенами.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.Номенклатура.Установить(Данные.Ключ.Номенклатура);
			НаборЗаписей.Отбор.Характеристика.Установить(Данные.Ключ.Характеристика);
			НаборЗаписей.Записать();
		КонецЦикла;
	Исключение
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
	КонецПопытки;
КонецПроцедуры



#КонецОбласти

#Область ПолучениеДанныхССайта

Функция ПолучитьДанныеССайта(URL, СсылкаНаОбъект = Неопределено)
	ВидЗапроса = "GET";
	АдресРесурса = ПолучитьАдресРесурса(URL, СсылкаНаОбъект);
	
	Результат = ОтправитьHTTPЗапрос(ВидЗапроса, АдресРесурса);
	Если Результат.Код >= 300 Тогда
		Ошибка = СформироватьОтвет(Результат);
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, Ошибка);
		Возврат Неопределено;
	КонецЕсли;
	
	ИменаСвойствСоЗначениямиДата = Новый Массив;
	ИменаСвойствСоЗначениямиДата.Добавить("updated_at");
	ИменаСвойствСоЗначениямиДата.Добавить("date_time");
		
	Данные = ПрочитатьСтрокуJSON(Результат.Тело, ИменаСвойствСоЗначениямиДата);
	Возврат Данные;
КонецФункции

Процедура ЗагрузитьЗаказыССайта() Экспорт
	Результат = ПолучитьДанныеССайта("exchanges");
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ Результат["errors"] = Неопределено Тогда
		Ошибка = Результат["errors"];
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, Ошибка);
		Возврат;			
	КонецЕсли;
	
	СписокИзменений = Результат["results"];
	Для Каждого Строка Из СписокИзменений Цикл
		ДатаОбновления = Строка["updated_at"];
		ТекущийДокумент = Строка["order"];
		ПервичныйКлюч = Строка["pk"];
		
		СсылкаНаОбъект = web_Документы.ДобавитьОбновитьЗаказ(ТекущийДокумент);
		Если НЕ СсылкаНаОбъект = Неопределено И ТипЗнч(СсылкаНаОбъект) = Тип("ДокументСсылка.ЗаказКлиента") Тогда
			ОчиститьЗаказНаСайте(ПервичныйКлюч, ДатаОбновления);	
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура ОчиститьЗаказНаСайте(ПервичныйКлюч, ДатаОбновления)
	Результат = ПолучитьДанныеССайта("exchanges", ПервичныйКлюч);
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ Результат["errors"] = Неопределено Тогда
		Ошибка = Результат["errors"];
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, Ошибка);
		Возврат;			
	КонецЕсли;
	
	СписокИзменений = Результат["results"];
	ДатаОбновленияНовая = СписокИзменений["updated_at"];
	Если ДатаОбновленияНовая = ДатаОбновления Тогда
		Результат = ОтправитьHTTPЗапрос("DELETE", ПолучитьАдресРесурса("exchanges", ПервичныйКлюч));		
	КонецЕсли;	
КонецПроцедуры

#КонецОбласти

#Область Подписки

Процедура web_РегистрацияОбменаПриЗаписи(Источник, Отказ) Экспорт
	//
	//	Подписка: РегистрацияОбмена
	//
	УстановитьПривилегированныйРежим(Истина);
	
	Если Источник.ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		СвязанныеСсылки = Новый Соответствие;
		web_ОбщегоНазначения.ЗаписатьЗависимыеСсылкиПоОбъекту(Источник.Ссылка, СвязанныеСсылки);
		Для Каждого Элемент Из СвязанныеСсылки Цикл
			МенеджерЗаписи = РегистрыСведений.web_СписокОбменаССайтом.СоздатьМенеджерЗаписи();
			МенеджерЗаписи.ПриоритетВыгрузки = Элемент.Значение; 
			МенеджерЗаписи.СсылкаНаОбъект = Элемент.Ключ; 
			МенеджерЗаписи.Записать();
		КонецЦикла;
	Исключение
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
	КонецПопытки;
	
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

Процедура web_РегистрацияИзмененияЦенПриЗаписи(Источник, Отказ, Замещение) Экспорт
	//
	//	Подписка: РегистрацияИзмененияЦен
	//
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТаблицаИзмененияЦен.Номенклатура КАК Номенклатура,
		|	ТаблицаИзмененияЦен.Цена КАК Цена,
		|	ТаблицаИзмененияЦен.ВидЦены КАК ВидЦены,
		|	ТаблицаИзмененияЦен.ХарактеристикаЦО КАК ХарактеристикаЦО
		|ПОМЕСТИТЬ ТаблицаИзмененияЦен
		|ИЗ
		|	&ТаблицаЦен КАК ТаблицаИзмененияЦен
		|ГДЕ
		|	ТаблицаИзмененияЦен.ВидЦены = &ВидЦены
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаИзмененияЦен.Номенклатура КАК Номенклатура,
		|	ХарактеристикиНоменклатуры.Ссылка КАК Характеристика,
		|	МАКСИМУМ(ТаблицаИзмененияЦен.Цена) КАК Цена,
		|	ТаблицаИзмененияЦен.ВидЦены КАК ВидЦены
		|ИЗ
		|	ТаблицаИзмененияЦен КАК ТаблицаИзмененияЦен
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ХарактеристикиНоменклатуры КАК ХарактеристикиНоменклатуры
		|		ПО ТаблицаИзмененияЦен.ХарактеристикаЦО = ХарактеристикиНоменклатуры.ХарактеристикаНоменклатурыДляЦенообразования
		|
		|СГРУППИРОВАТЬ ПО
		|	ТаблицаИзмененияЦен.Номенклатура,
		|	ХарактеристикиНоменклатуры.Ссылка,
		|	ТаблицаИзмененияЦен.ВидЦены";
	
	Запрос.УстановитьПараметр("ТаблицаЦен", Источник.Выгрузить());
	Запрос.УстановитьПараметр("ВидЦены", web_ОбщегоНазначения.ПолучитьНастройку_ВидЦены());
	
	РезультатЗапроса = Запрос.Выполнить();              
	ТаблицаИзмененияЦен = РезультатЗапроса.Выгрузить();
		
	РегистрыСведений.web_СписокОбменаЦенами.ДобавитьЗаписи(ТаблицаИзмененияЦен);
	
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

Процедура web_РегистрацияДокументовПриЗаписи(Источник, Отказ) Экспорт
	//
	//	Подписка: РегистрацияДокументов
	//
	УстановитьПривилегированныйРежим(Истина);
	
	Если Источник.ПометкаУдаления ИЛИ Источник.web_ЗагруженССайта Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		СвязанныеСсылки = Новый Соответствие;
		web_ОбщегоНазначения.ЗаписатьЗависимыеСсылкиПоОбъекту(Источник.Ссылка, СвязанныеСсылки);
		Для Каждого Элемент Из СвязанныеСсылки Цикл
			МенеджерЗаписи = РегистрыСведений.web_СписокОбменаССайтом.СоздатьМенеджерЗаписи();
			МенеджерЗаписи.ПриоритетВыгрузки = Элемент.Значение; 
			МенеджерЗаписи.СсылкаНаОбъект = Элемент.Ключ; 
			МенеджерЗаписи.Записать();
		КонецЦикла;
	Исключение
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
	КонецПопытки;
	
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

#КонецОбласти


#Область МетодыОбмена

Функция ОтправитьОбъектНаСайт(URL, СсылкаНаОбъект, ДанныеДляЗапроса, ПолнаяВыгрузка = Ложь) Экспорт
	//
	//	Используется для передачи на сайт любых объектов, кроме изображений (MultipartFormData)
	//
	Если ДанныеДляЗапроса = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	uid = XMLСтрока(СсылкаНаОбъект);
	web_ОбщегоНазначения.Трассировка("uid:"+uid, Истина);

	Обновление = Ложь;
	Если ОбъектЕстьНаСайте(URL, СсылкаНаОбъект) Тогда
		Если НЕ ПолнаяВыгрузка Тогда
			Возврат СсылкаНаОбъект;
		КонецЕсли;
		Обновление = Истина;	
	КонецЕсли;
	
	Если НЕ Обновление Тогда
		ДанныеДляЗапроса.Вставить("id", uid);
		АдресРесурса = ПолучитьАдресРесурса(URL); // ??? , СсылкаНаОбъект
		ВидЗапроса = "POST";
	Иначе
		АдресРесурса = ПолучитьАдресРесурса(URL, СсылкаНаОбъект);
		ВидЗапроса = "PATCH";
	КонецЕсли;             
	Результат = ОтправитьHTTPЗапрос(ВидЗапроса, АдресРесурса, ДанныеДляЗапроса);
	
	Если Результат.Код >= 400 Тогда
		Ошибка = СформироватьОтвет(Результат);
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, Ошибка);
	
		Возврат Неопределено
	КонецЕсли;
	
	Возврат СсылкаНаОбъект;	
КонецФункции

Функция ОтправитьMultipartFormData(URL, СсылкаНаОбъект, ПараметрыТелаЗапроса) Экспорт
	//
	//	Отправка запроса в формате multipart/form-data. Используется для записи изображений
	//
	//	Параметры:
	//
	//		URL -- (Строка) images
	//
	//		СсылкаНаОбъект -- (Строка) uid объекта изображения
	//
	//		ПараметрыТелаЗапроса -- (Массив) массив структур параметров запроса 
	//			(см. web_Справочники.СформироватьДанныеИзображения)
	//
	//
	Если ПараметрыТелаЗапроса = Неопределено Тогда
		Возврат Неопределено;	
	КонецЕсли;
	
	Разделитель = СтрЗаменить(Новый УникальныйИдентификатор(), "-", "");
	
	Тело = Новый ПотокВПамяти();
	ПараметрКодировкаТекста = Неопределено;
	ПараметрПорядокБайтов = Неопределено;
	ПараметрРазделительСтрок = web_ОбщегоНазначения.СимволыПСВК();
	ПараметрКонвертируемыйРазделительСтрок = "";
	ПараметрЗаписатьBOM = Неопределено;
	
	ЗаписьДанных = Новый ЗаписьДанных(
		Тело,
		,
		, 
		ПараметрРазделительСтрок, 
		,
		
	);
	
	Для каждого Параметр из ПараметрыТелаЗапроса Цикл 
		Если Параметр.ЭтоИзображение Тогда
			MFD_ДобавитьИзображение(
				ЗаписьДанных, 
				Разделитель,
				Параметр.ИмяПараметра,
				Параметр.ИмяФайла,
				ПолучитьТипИзображения(Параметр.Расширение),
				Параметр.ДвоичныеДанные
			);	
		Иначе
			MFD_ДобавитьПараметр(
				ЗаписьДанных, 
				Разделитель,
				Параметр.ИмяПараметра,
				Параметр.ЗначениеПараметра	
			);
		КонецЕсли;
	КонецЦикла;

	ЗаписьДанных.ЗаписатьСтроку("--" + Разделитель + "--"); //  + Символы.ПС
	ЗаписьДанных.Закрыть();
	
	ТелоЗапроса = Тело.ЗакрытьИПолучитьДвоичныеДанные();
	
	Обновление = ОбъектЕстьНаСайте(URL, СсылкаНаОбъект);
	Если Обновление Тогда
		АдресРесурса = ПолучитьАдресРесурса(URL, СсылкаНаОбъект);
		ВидЗапроса = "PATCH";
	Иначе
		АдресРесурса = ПолучитьАдресРесурса(URL);
		ВидЗапроса = "POST";
	КонецЕсли;	
	
	Результат = ОтправитьHTTPЗапрос(ВидЗапроса, АдресРесурса, ТелоЗапроса, Разделитель);
	Если Результат.Код >= 300 Тогда
		Ошибка = СформироватьОтвет(Результат);
		Сообщить(Ошибка);
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, Ошибка);
		Возврат Неопределено;
	КонецЕсли;	
	Возврат СсылкаНаОбъект;
КонецФункции

Функция ОтправитьHTTPЗапрос(Метод, АдресРесурса, ДанныеДляЗапроса = Неопределено, Разделитель = Неопределено) Экспорт
	
	НастройкиСоединения = СформироватьНастройкиСоединения();
	
	HTTPСоединение = Новый HTTPСоединение(
		НастройкиСоединения.Адрес,
		НастройкиСоединения.Порт,
		,,,
		30,
		НастройкиСоединения.SSL,
	);

	web_ОбщегоНазначения.Трассировка("Метод: "+Метод+": АдресРесурса["+АдресРесурса+"]" );	
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Authorization", СтрШаблон("Token %1", web_ОбщегоНазначения.ПолучитьНастройку_Токен()));
	
	ТекстЗапроса = "";
	
	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса, Заголовки);
	Если НЕ ДанныеДляЗапроса = Неопределено Тогда
		Если ТипЗнч(ДанныеДляЗапроса) = Тип("Соответствие") Тогда
			Заголовки.Вставить("Content-Type", "application/json");
			HTTPЗапрос.УстановитьТелоИзСтроки(
				СформироватьJSON(ДанныеДляЗапроса), 
				КодировкаТекста.UTF8, 
				ИспользованиеByteOrderMark.НеИспользовать
			);
		Иначе
			Заголовки.Вставить("Content-Type", СтрШаблон("multipart/form-data; boundary=%1", Разделитель));
			Размер = ДанныеДляЗапроса.Размер();
			Заголовки.Вставить("Content-Length", XMLСтрока(Размер));
			HTTPЗапрос.УстановитьТелоИзДвоичныхДанных(ДанныеДляЗапроса);
		КонецЕсли;
		
		ТекстЗапроса = HTTPЗапрос.ПолучитьТелоКакСтроку();
	КонецЕсли;

	Для Каждого Заголовок Из Заголовки Цикл
		ТекстЗаголовка = "Заголовок: "+Строка(Заголовок.Ключ)+" :["+Строка(Заголовок.Значение)+"]";
		web_ОбщегоНазначения.Трассировка(ТекстЗаголовка);
	КонецЦикла;
	
	web_ОбщегоНазначения.Трассировка("Запрос: "+Символы.ПС+ТекстЗапроса);
	
	Результат = HTTPСоединение.ВызватьHTTPМетод(Метод, HTTPЗапрос);
	ДанныеВозврата = Новый Структура(
		"Код, Тело", 
		Результат.КодСостояния, 
		Результат.ПолучитьТелоКакСтроку()
	);
	КодВозврата = ДанныеВозврата.Код;
	web_ОбщегоНазначения.Трассировка("КодВозврата: "+КодВозврата);
	Возврат ДанныеВозврата;
КонецФункции

#КонецОбласти   
