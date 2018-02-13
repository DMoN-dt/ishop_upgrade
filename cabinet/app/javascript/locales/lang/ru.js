export default {

ru: {
	messages: {
	  Error: 'Ошибка',
      error_unknown: 'Произошла неизвестная ошибка',
      access_denied: 'Доступ запрещён!',
      item_not_found: 'Элемент не найден!',
      absent: 'отсутствует',
      time_op: 'время обработки',
      seconds: 'секунд',
      op_rows: 'обработано %{cnt} строк',
      Op_rows: 'Обработано %{cnt} строк',
      of_found: 'от найденных',
      repaired: 'исправлено',
      info_hidden: 'Информация скрыта',
      undefined: 'не известно',
      undef: 'н/о',
      is_free: 'бесплатно',
      must_confirm: 'Требуется подтверждение операции.',
      unable_to_save_changes: "Не удалось сохранить изменения !",
      no_changes_made: "Изменения не произведены !",
      required_field: "Обязательно для заполнения",
      save_changes: "Сохранить изменения ?",
      skip_changes: "Отбросить изменения ?",
      not_saved_before_new_group: "Вы не сохранили изменения в группе \"{group_name}\" и переключаетесь на другую группу.",
      discard_group_changes: "Отбросить изменения и перейти к выбранной группе ?",
      save_group_changes: "Сохранить изменения до перехода к выбранной группе ?",
	  
	  choose_smth: 'Выбор...',
	  choose_group: 'Выбор группы',
	  choose_brand: 'Выбор брэнда',
	  choose_country: 'Выбор страны',
	  choose_measure_unit: 'Выбор единицы измерения',
	},
	
	buttons: {
		save: 'Сохранить',
		edit: 'Редактировать',
		edit_quit: 'Выйти из редактирования',
		Delete: 'Удалить',
		Create: 'Создать',
		Cancel: 'Отмена',
		Change: 'Изменить',
		OK: 'OK',
		Yes: 'Да',
		No: 'Нет',
		store_save_changes: 'Записать изменения',
	},
	
	cabinet: {
		bcb_title: 'Личный кабинет',
		bcb_sellers: 'Продавцы',
		bcb_ecommerce: 'Торговля',
	},
	
	seller: {
		bcb_title: 'Продавец', // № {id}
		
		prodgroups: {
			bcb_title: 'Группы товаров',
			title_list_index: 'Группы Товаров Продавца',
			
			all_groups_name: 'ВСЕ ГРУППЫ',
			root_group_name: 'Корневая группа',
			group_name: 'Наименование группы:',
			group_descr: 'Краткое описание группы:',
			sort_order: 'Порядок сортировки:',
			group_active: 'Группа активна',
			group_inactive: 'Группа не активна',
			parent_group: 'Родительская группа:',
			parent_group_inactive: 'Родительская группа не активна',
			groups_changes_saved: 'Все изменения в группах успешно сохранены',
			select_parent_group: 'Выберите родительскую группу в списке групп',
			group_tree_not_updated: 'Данная группа была изменена позднее построения зависимостей дочерних групп, возможно она содержит подгруппы.',
			
			btn_find_subgroups: 'Найти подгруппы',
			btn_goto_products: 'Перейти к Товарам',
			btn_add_new: 'Добавить группу',
			group_name_new: 'Новая группа',
			group_creation: 'Создание новой группы',
			groups_changes: 'Изменения в группах',
			
			group_deletion: 'Удаление группы',
			delete_empty_group_only: 'Удалить только если группа не содержит товаров',
			group_deleted_title: 'Группа удалена! ',
			group_deleted_already: 'Указанная группа не существует, возможно она уже удалена!',
			groups_deleted: 'Всего удалено групп, включая подгруппы: {count}. ',
			groups_deleted_no_products: 'В группе и подгруппах не содержалось товаров. ',
			group_deleted_no_products: 'В группе не содержалось товаров.',
			group_products_deleted: 'В группе удалено товаров: {count}. ',
			group_prod_images_deleted: 'Также удалено изображений товаров: {count}. ',
			group_prod_images_skipped: 'Изображения товаров отсутствовали или не удалялись.',
		},
		
		products: {
			bcb_title: 'Товары',
			title_list_index: 'Товары',
			bcb_item_title: 'Товар',
			
			title_default_group_opts: 'Настройки групп по-умолчанию:',
			title_group_opts: 'Настройки для товаров группы:',
			inherit: 'Наследовать',
			inherited: 'унаследовано',
			measure_unit: 'Единица измерения:',
			select_measure_unit: 'Выберите единицу измерения из списка',
			gov_tax_system: 'Система налогообложения:',
			select_gov_tax_system: 'Выберите налогообложение из списка',
			gov_tax: 'Ставка налога:',
			select_gov_tax: 'Выберите ставку из списка',
			currency: 'Валюта загружаемых цен:',
			select_currency: 'Выберите валюту из списка',
			price_include_tax: 'Загружаемые цены товаров уже содержат налог ?',
			imported_prices_w_tax: 'Загружаемые цены уже содержат налог',
			imported_prices_wo_tax: 'Загружаемые цены без налога',
			price_w_tax: 'Цены с налогом',
			price_wo_tax: 'Цены без налога',
			totals_taxes_info: 'Информация о налогах влияет на итоговые суммы в кассовых чеках!',
			last_updated: 'Последнее изменение',
			last_saved_update: 'Последнее записанное изменение',
			
			btn_create: 'Создать товар',
			btn_show_info: 'Просмотр',
			
			name: 'Наименование',
			prod_artikul: 'Артикул товара',
			seller_own_prod_id: 'Учётный код товара',
			product_code: 'Код продукта',
			seller_group_id: 'Группа',
			active: 'Активен',
			to_delete: 'Отмечен к удалению',
			is_popular: 'Популярный товар',
			desc_thumb: 'Описание краткое (для списков товаров)',
			desc_full: 'Описание полное',
			tax_system: 'Налогообложение',
			tax_rate: 'Ставка налога',
			brand: 'Брэнд',
			brand_country: 'Страна брэнда',
			brand_manufacture_country: 'Страна изготовления',
			manufacture_country: 'Страна изготовления',
			
			sell_props_title: 'Публикация товара и возможность продажи',
			show_at_estore: 'Показывать товар в ИМ',
			show_price_at_estore: 'Показывать цену в ИМ',
			sell_at_estore: 'Продавать в ИМ',
			not_for_sale_at_estore: 'Не продаётся в ИМ',
			not_on_sale: 'Товара нет в продаже',
			allow_offline_sales: 'Продавать в оффлайне',
			
			lot_price_entire: 'Цена установлена за всё предложение',
			lot_price_unit: 'Цена установлена за составную единицу',
			
			lot_units_count: 'Количество составных частей',
			lot_units_measure_type: 'Ед.изм. составной части',
			
			current_base_price: 'Текущая базовая цена',


		}
	}
}

}