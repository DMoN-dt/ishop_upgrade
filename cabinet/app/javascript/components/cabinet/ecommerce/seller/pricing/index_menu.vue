<template lang='pug'>
  div.page-block.padding-more.menu-block
    h1 {{ $t("seller.pricing.title_list_index") }}
    
    .row
      .col-md-9
        .row
          .menu-block.block-col.block-wd-half
            .menu-item
              .item-title: router-link(:to="'price_types'" append) {{ $t("seller.pricing.bcb_prices_title") }}
              .item-desc Управление типами цен: розничная, мелкооптовая, оптовая, дилерская и прочие
            .menu-item
              .item-title: router-link(:to="'rules'" append) {{ $t("seller.pricing.menu_rules_title") }}
              .item-desc Использование фиксированных цен, применение коэффициентов к ценам поставщиков

          .menu-block.block-col.block-wd-half
            .menu-item
              .item-title: router-link(:to="'fixed_prices'" append) {{ $t("seller.pricing.bcb_fixed_prices_title") }}
              .item-desc Фиксированные цены могут иметь приоритет перед расчётными величинами
            .menu-item
              .item-title: router-link(:to="'maths'" append) {{ $t("seller.pricing.menu_maths_title") }}
              .item-desc Методы, условия, округление и периоды действия правил


</template>

<script>

export default {
  data (){return {data: null}},
  methods: {

  },
  
  
  created (){
      // this.showSellerGroups()
  },
  
  
  watch: {

  },
  
  
  computed: {
    //title (){return this.$store.state.news.title},
  },
}
</script>