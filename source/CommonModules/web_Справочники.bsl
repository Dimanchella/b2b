#Область ProductsGroup

Функция ОтправитьГруппуНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"products_groups", 
		СсылкаНаОбъект, 
		СформироватьДанныеГруппыНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеГруппыНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Номенклатура.Наименование КАК Наименование,
		|	Номенклатура.Родитель КАК Родитель
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура
		|ГДЕ
		|	Номенклатура.Ссылка = &Ссылка
		|	И Номенклатура.ЭтоГруппа = ИСТИНА";
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Данные = Новый Соответствие;
	Данные.Вставить("title", 	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Наименование));
	Данные.Вставить("parent",	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Родитель));	

	Возврат Данные;
КонецФункции

#КонецОбласти

#Область Products

Функция ОтправитьНоменклатуру(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"products", 
		СсылкаНаОбъект, 
		СформироватьДанныеНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Номенклатура.Наименование КАК Наименование,
		|	Номенклатура.Родитель КАК Родитель,
		|	Номенклатура.ВидНоменклатуры КАК ВидНоменклатуры,
		|	Номенклатура.ИспользованиеХарактеристик КАК ИспользованиеХарактеристик
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура
		|ГДЕ
		|	Номенклатура.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();	
	
	Данные = Новый Соответствие;
	Данные.Вставить("full_name", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Наименование));
	Данные.Вставить("type_of_product",	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.ВидНоменклатуры));
	Данные.Вставить("group", 			web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Родитель));
	
	Если Выборка.ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.НеИспользовать Тогда
		use_characteristic = "NU";
	ИначеЕсли Выборка.ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ИндивидуальныеДляНоменклатуры Тогда
		use_characteristic = "IND";
	ИначеЕсли Выборка.ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеДляВидаНоменклатуры Тогда
		use_characteristic = "GST";
	ИначеЕсли Выборка.ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеСДругимВидомНоменклатуры Тогда
		use_characteristic = "GOT";
	КонецЕсли;
	Данные.Вставить("use_characteristic", use_characteristic);
	
	Возврат Данные;
КонецФункции

#КонецОбласти

#Область Images

Функция ЭтоГрафическийФайл(Расширение) Экспорт
	НРегРасширение = НРег(Расширение);
	РасширенияИзображений = ".jpg.jpeg.png.gif.bmp.ico.tif.emf.wmf";
	Возврат Найти(РасширенияИзображений, НРегРасширение) > 0;
КонецФункции

Функция ЗаполнитьДанныеИзображения(Выборка)
	ДанныеИзображения = Новый Структура(
		"Расширение,ИмяФайла,ДвоичныеДанные",
		Неопределено,
		Неопределено,
		Неопределено,
	);
	
	Попытка
		Если Выборка.ТипХраненияФайла = Перечисления.ТипыХраненияФайлов.ВИнформационнойБазе Тогда
			Если НЕ ТипЗнч(Выборка.Хранилище) = Тип("ХранилищеЗначения") Тогда
				Возврат Неопределено;	
			КонецЕсли;
			ДвоичныеДанные = Выборка.Хранилище.Получить();
		Иначе
			ПолноеИмяФайла = Выборка.ПутьНаДиске + Выборка.ПутьКФайлу;
			ПутьСФайлом = Новый Файл(ПолноеИмяФайла);
			Если НЕ ПутьСФайлом.Существует() Тогда
				Возврат Неопределено;	
			КонецЕсли;
			ДвоичныеДанные = Новый ДвоичныеДанные(ПолноеИмяФайла);
		КонецЕсли;
		
		Если ДвоичныеДанные = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
		ЗаполнитьЗначенияСвойств(ДанныеИзображения, Выборка);
		ДанныеИзображения.ДвоичныеДанные = ДвоичныеДанные;
	Исключение
		Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
		Возврат Неопределено;
	КонецПопытки;
	
	Возврат ДанныеИзображения;
КонецФункции

Функция ПолучитьДанныеИзображения(СсылкаНаОбъект)
	//
	//
	//
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	НоменклатураПрисоединенныеФайлы.Ссылка КАК Ссылка,
		|	НоменклатураПрисоединенныеФайлы.Наименование КАК ИмяФайла,
		|	НоменклатураПрисоединенныеФайлы.ВладелецФайла КАК ВладелецФайла,
		|	НоменклатураПрисоединенныеФайлы.Расширение КАК Расширение,
		|	НоменклатураПрисоединенныеФайлы.ПутьКФайлу КАК ПутьКФайлу,
		|	НоменклатураПрисоединенныеФайлы.ТипХраненияФайла КАК ТипХраненияФайла,
		|	НоменклатураПрисоединенныеФайлы.Том.ПолныйПутьWindows КАК ПутьНаДиске,
		|	ДвоичныеДанныеФайлов.ДвоичныеДанныеФайла КАК Хранилище
		|ИЗ
		|	Справочник.НоменклатураПрисоединенныеФайлы КАК НоменклатураПрисоединенныеФайлы
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДвоичныеДанныеФайлов КАК ДвоичныеДанныеФайлов
		|		ПО НоменклатураПрисоединенныеФайлы.Ссылка = ДвоичныеДанныеФайлов.Файл.Ссылка
		|ГДЕ
		|	НоменклатураПрисоединенныеФайлы.Ссылка = &Ссылка
		|	И НоменклатураПрисоединенныеФайлы.ПометкаУдаления = ЛОЖЬ";
	
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
		
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Если НЕ ЭтоГрафическийФайл(Выборка.Расширение) Тогда
		Возврат Неопределено;	
	КонецЕсли;
	
	Возврат ЗаполнитьДанныеИзображения(Выборка)
КонецФункции

Функция СформироватьДанныеИзображения(СсылкаНаОбъект, ПолнаяВыгрузка)
	//
	//	см. ОтправитьИзображение
	//
	Данные = ПолучитьДанныеИзображения(СсылкаНаОбъект);	
	Если Данные = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	uid = XMLСтрока(СсылкаНаОбъект);
	product = XMLСтрока(СсылкаНаОбъект.ВладелецФайла);
	
	ТелоЗапроса = Новый Массив;
	ТелоЗапроса.Добавить(web_Обмен.MFD_ЗаполнитьПараметр("id", uid));
	ТелоЗапроса.Добавить(web_Обмен.MFD_ЗаполнитьПараметр("product", product));
	ТелоЗапроса.Добавить(web_Обмен.MFD_ЗаполнитьПараметр(
		"image",, 
		Данные.ИмяФайла, 
		Данные.Расширение,
		Данные.ДвоичныеДанные	
	));
	
	Возврат ТелоЗапроса;
КонецФункции

Функция ОтправитьИзображение(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	//
	//	см. НоменклатураПрисоединенныеФайлы.ОтправитьНаСайт
	//
	Если НЕ ЗначениеЗаполнено(СсылкаНаОбъект.ВладелецФайла) Тогда
		Возврат Неопределено;
	КонецЕсли;

	web_ОбщегоНазначения.Трассировка(СсылкаНаОбъект.ВладелецФайла);	
	
	Возврат web_Обмен.ОтправитьMultipartFormData(
		"images", 
		СсылкаНаОбъект, 
		СформироватьДанныеИзображения(СсылкаНаОбъект, ПолнаяВыгрузка)
	);
КонецФункции

#КонецОбласти

#Область Users

Функция ОтправитьПользователя(СсылкаНаОбъект, Пароль, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"users", 
		СсылкаНаОбъект, 
		СформироватьДанныеПользователя(СсылкаНаОбъект, Пароль, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеПользователя(СсылкаНаОбъект, Пароль = Неопределено, ПолнаяВыгрузка)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Контрагенты.ИНН КАК ИНН,
		|	Контрагенты.НаименованиеПолное КАК НаименованиеПолное,
		|	КонтрагентыКонтактнаяИнформация.Представление КАК Представление
		|ИЗ
		|	Справочник.Контрагенты.КонтактнаяИнформация КАК КонтрагентыКонтактнаяИнформация
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Контрагенты
		|		ПО КонтрагентыКонтактнаяИнформация.Ссылка = Контрагенты.Ссылка
		|ГДЕ
		|	Контрагенты.Ссылка = &Ссылка
		|	И КонтрагентыКонтактнаяИнформация.Тип = &Тип
		|	И КонтрагентыКонтактнаяИнформация.Вид = &Вид";
	
	Запрос.УстановитьПараметр("Вид", web_ОбщегоНазначения.ПолучитьНастройку_ВидКИEmail());
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
	Запрос.УстановитьПараметр("Тип", Перечисления.ТипыКонтактнойИнформации.АдресЭлектроннойПочты);
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Данные = Новый Соответствие;
	Если Выборка.ИНН = Неопределено Тогда
		Информация = "У контрагента не заполнен ИНН.";
		Сообщить(Информация);
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Предупреждение,,, Информация);
		Возврат Неопределено;
	КонецЕсли;
	Данные.Вставить("username", 	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.ИНН));
	
	Если Выборка.Представление = Неопределено Тогда
		Информация = "У контрагента не заполнено поле Email для сайта.";
		Сообщить(Информация);
		ЗаписьЖурналаРегистрации("Django", УровеньЖурналаРегистрации.Предупреждение,,, Информация);
		Возврат Неопределено;
	КонецЕсли;
	Данные.Вставить("email", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Представление));
	
	Данные.Вставить("contractor",	web_ОбщегоНазначения.ДобавитьЗначение(СсылкаНаОбъект));
	Данные.Вставить("full_name",	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.НаименованиеПолное));
	
	Если ЗначениеЗаполнено(Пароль) Тогда
		Данные.Вставить("password",	web_ОбщегоНазначения.ДобавитьЗначение(Пароль));
	КонецЕсли;
	
	Возврат Данные;
КонецФункции

#КонецОбласти

#Область TypesOfProducts

Функция ОтправитьВидНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"types_of_products", 
		СсылкаНаОбъект, 
		СформироватьДанныеВидаНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеВидаНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка)
	Данные = Новый Соответствие;
	Данные.Вставить("name",	web_ОбщегоНазначения.ДобавитьЗначение(СсылкаНаОбъект.Наименование));	
	Возврат Данные;
КонецФункции

#КонецОбласти

#Область Characteristics

Функция ОтправитьХарактеристикуНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"characteristics", 
		СсылкаНаОбъект, 
		СформироватьДанныеХарактеристикиНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеХарактеристикиНоменклатуры(СсылкаНаОбъект, ПолнаяВыгрузка)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ХарактеристикиНоменклатуры.Наименование КАК Наименование,
		|	ХарактеристикиНоменклатуры.Владелец КАК Владелец
		|ИЗ
		|	Справочник.ХарактеристикиНоменклатуры КАК ХарактеристикиНоменклатуры
		|ГДЕ
		|	ХарактеристикиНоменклатуры.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Данные = Новый Соответствие;
	Данные.Вставить("name", web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Наименование));
	
	Если ЗначениеЗаполнено(Выборка.Владелец) Тогда
		Владелец = web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Владелец);
		Если ТипЗнч(Выборка.Владелец) = Тип("СправочникСсылка.Номенклатура") Тогда
			Данные.Вставить("product", Владелец);
		ИначеЕсли ТипЗнч(Выборка.Владелец) = Тип("СправочникСсылка.ВидыНоменклатуры") Тогда
			Данные.Вставить("type_of_product", Владелец);
		КонецЕсли;
	КонецЕсли;
	Возврат Данные;
КонецФункции

#КонецОбласти

#Область Organizations

Функция ОтправитьОрганизацию(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"organizations", 
		СсылкаНаОбъект, 
		СформироватьДанныеОрганизации(СсылкаНаОбъект, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеОрганизации(СсылкаНаОбъект, ПолнаяВыгрузка)
	Данные = Новый Соответствие;
	Данные.Вставить("name", web_ОбщегоНазначения.ДобавитьЗначение(СсылкаНаОбъект.Наименование));	
	Возврат Данные;
КонецФункции

#КонецОбласти 

#Область Partners

Функция ОтправитьПартнера(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"partners", 
		СсылкаНаОбъект, 
		СформироватьДанныеПартнера(СсылкаНаОбъект, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеПартнера(СсылкаНаОбъект, ПолнаяВыгрузка)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Партнеры.Наименование КАК Наименование,
		|	Партнеры.НаименованиеПолное КАК НаименованиеПолное
		|ИЗ
		|	Справочник.Партнеры КАК Партнеры
		|ГДЕ
		|	Партнеры.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Данные = Новый Соответствие;
	Данные.Вставить("name", 		web_ОбщегоНазначения.ДобавитьЗначение(СсылкаНаОбъект.Наименование));
	Данные.Вставить("full_name",	web_ОбщегоНазначения.ДобавитьЗначение(СсылкаНаОбъект.НаименованиеПолное));
	Возврат Данные;
КонецФункции

#КонецОбласти

#Область Contractors

Функция ОтправитьКонтрагента(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"contractors", 
		СсылкаНаОбъект, 
		СформироватьДанныеКонтрагента(СсылкаНаОбъект, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеКонтрагента(СсылкаНаОбъект, ПолнаяВыгрузка)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Контрагенты.ИНН КАК ИНН,
		|	Контрагенты.КПП КАК КПП,
		|	Контрагенты.Наименование КАК Наименование,
		|	Контрагенты.НаименованиеПолное КАК НаименованиеПолное,
		|	Контрагенты.Партнер КАК Партнер,
		|	Контрагенты.ЮрФизЛицо КАК ЮрФизЛицо
		|ИЗ
		|	Справочник.Контрагенты КАК Контрагенты
		|ГДЕ
		|	Контрагенты.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
		
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Данные = Новый Соответствие;
	Данные.Вставить("inn", 			web_ОбщегоНазначения.ДобавитьЗначение(Выборка.ИНН));
	Данные.Вставить("kpp", 			web_ОбщегоНазначения.ДобавитьЗначение(Выборка.КПП));
	Данные.Вставить("name", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Наименование));
	Данные.Вставить("full_name",	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.НаименованиеПолное));
	Данные.Вставить("partner", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Партнер));
	
	Если Выборка.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ЮрЛицо Тогда	
		status = "COM";	
	ИначеЕсли Выборка.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо Тогда
		status = "PER";
	ИначеЕсли Выборка.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ЮрЛицоНеРезидент Тогда
		status = "OCOM";
	ИначеЕсли Выборка.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ИндивидуальныйПредприниматель Тогда
		status = "IND";
	КонецЕсли;	
	Данные.Вставить("status", status);
	
	Возврат Данные;
КонецФункции

#КонецОбласти   

#Область Agreements

Функция ОтправитьСоглашение(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"agreements", 
		СсылкаНаОбъект, 
		СформироватьДанныеСоглашения(СсылкаНаОбъект, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеСоглашения(СсылкаНаОбъект, ПолнаяВыгрузка)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СоглашенияСКлиентами.Наименование КАК Наименование,
		|	СоглашенияСКлиентами.Номер КАК Номер,
		|	СоглашенияСКлиентами.Дата КАК Дата,
		|	СоглашенияСКлиентами.Партнер КАК Партнер,
		|	СоглашенияСКлиентами.Контрагент КАК Контрагент,
		|	СоглашенияСКлиентами.Организация КАК Организация
		|ИЗ
		|	Справочник.СоглашенияСКлиентами КАК СоглашенияСКлиентами
		|ГДЕ
		|	СоглашенияСКлиентами.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
		
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Данные = Новый Соответствие;
	Данные.Вставить("name", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Наименование));
	Данные.Вставить("number", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Номер));
	Данные.Вставить("date", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Дата));
	Данные.Вставить("partner", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Партнер));
	Данные.Вставить("contractor", 	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Контрагент));
	Данные.Вставить("organization",	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Организация));
	
	Возврат Данные;
КонецФункции

#КонецОбласти

#Область Contracts

Функция ОтправитьДоговор(СсылкаНаОбъект, ПолнаяВыгрузка) Экспорт
	Возврат web_Обмен.ОтправитьОбъектНаСайт(
		"contracts", 
		СсылкаНаОбъект, 
		СформироватьДанныеДоговора(СсылкаНаОбъект, ПолнаяВыгрузка), 
		ПолнаяВыгрузка
	);
КонецФункции

Функция СформироватьДанныеДоговора(СсылкаНаОбъект, ПолнаяВыгрузка)	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.Наименование КАК Наименование,
		|	ДоговорыКонтрагентов.Номер КАК Номер,
		|	ДоговорыКонтрагентов.Дата КАК Дата,
		|	ДоговорыКонтрагентов.Партнер КАК Партнер,
		|	ДоговорыКонтрагентов.Контрагент КАК Контрагент,
		|	ДоговорыКонтрагентов.Организация КАК Организация
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
		
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Данные = Новый Соответствие;
	Данные.Вставить("name", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Наименование));
	Данные.Вставить("number", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Номер));
	Данные.Вставить("date", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Дата));
	Данные.Вставить("partner", 		web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Партнер));
	Данные.Вставить("contractor",	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Контрагент));
	Данные.Вставить("organization",	web_ОбщегоНазначения.ДобавитьЗначение(Выборка.Организация));
	Данные.Вставить("default", Ложь);
	
	Возврат Данные;
КонецФункции

#КонецОбласти