﻿
&НаСервереБезКонтекста
Процедура ВыполнитьПолныйОбменНаСервере()
	web_Обмен.ВыполнитьОбменЦенамиССайтом();
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПолныйОбмен(Команда)
	ВыполнитьПолныйОбменНаСервере();
	Элементы.Список.Обновить();
КонецПроцедуры

&НаСервере
Процедура ЗарегистрироватьОбъектыНаВыгрузкуНаСервере()
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЦеныНоменклатурыСрезПоследних.Номенклатура КАК Номенклатура,
		|	ЦеныНоменклатурыСрезПоследних.ВидЦены КАК ВидЦены,
		|	ЦеныНоменклатурыСрезПоследних.Характеристика КАК Характеристика,
		|	ЦеныНоменклатурыСрезПоследних.Цена КАК Цена
		|ПОМЕСТИТЬ СписокЦен
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(, ВидЦены = &ВидЦены) КАК ЦеныНоменклатурыСрезПоследних
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ЦеныНоменклатуры25СрезПоследних.Номенклатура,
		|	ЦеныНоменклатуры25СрезПоследних.ВидЦены,
		|	ХарактеристикиНоменклатуры.Ссылка,
		|	ЦеныНоменклатуры25СрезПоследних.Цена
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры25.СрезПоследних(, ВидЦены = &ВидЦены) КАК ЦеныНоменклатуры25СрезПоследних
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ХарактеристикиНоменклатуры КАК ХарактеристикиНоменклатуры
		|		ПО ЦеныНоменклатуры25СрезПоследних.ХарактеристикаЦО = ХарактеристикиНоменклатуры.ХарактеристикаНоменклатурыДляЦенообразования
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СписокЦен.Номенклатура КАК Номенклатура,
		|	СписокЦен.Характеристика КАК Характеристика,
		|	МАКСИМУМ(СписокЦен.Цена) КАК Цена
		|ИЗ
		|	СписокЦен КАК СписокЦен
		|ГДЕ
		|	СписокЦен.Номенклатура.ЭтоГруппа = ЛОЖЬ
		|
		|СГРУППИРОВАТЬ ПО
		|	СписокЦен.Номенклатура,
		|	СписокЦен.Характеристика";
	Запрос.УстановитьПараметр("ВидЦены", web_ОбщегоНазначения.ПолучитьНастройку_ВидЦены());	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		ТаблицаСсылок = РезультатЗапроса.Выгрузить();	
		НаборВыгружаемыхЦен = РегистрыСведений.web_СписокОбменаЦенами.СоздатьНаборЗаписей();
		НаборВыгружаемыхЦен.Очистить();
		НаборВыгружаемыхЦен.Загрузить(ТаблицаСсылок);
        НаборВыгружаемыхЦен.Записать();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ЗарегистрироватьОбъектыНаВыгрузку(Команда)
	ЗарегистрироватьОбъектыНаВыгрузкуНаСервере();
	Элементы.Список.Обновить();
КонецПроцедуры
