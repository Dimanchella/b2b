﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	ОтправитьНаСайт(ПараметрКоманды);
КонецПроцедуры

&НаСервере
Процедура ОтправитьНаСайт(СсылкаНаОбъект)
	Пароль = "123456";
	КонтрагентСсылка = web_Справочники.ОтправитьПользователя(СсылкаНаОбъект, Пароль, Истина);
	Если НЕ КонтрагентСсылка = Неопределено Тогда
		Сообщить(СтрШаблон(
			"Пользователь %1 (%2) отправлен на сайт.", 
			КонтрагентСсылка.НаименованиеПолное, 
			КонтрагентСсылка.ИНН
		));
	КонецЕсли;
КонецПроцедуры
