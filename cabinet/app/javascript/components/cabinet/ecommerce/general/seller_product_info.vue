<template lang="pug">
  .product-edit(v-if="data")
    .page-controls
      button.btn.btn-link(@click="page = 'summary'") {{ $t("seller.products.btn_page_info_general") }}
      button.btn.btn-link(@click="page = 'availability'") {{ $t("seller.products.btn_page_info_availability") }}
      button.btn.btn-link(@click="page = 'pricing'") {{ $t("seller.products.btn_page_info_pricing") }}

    product-info-summary(v-show="page == 'summary'" :data="data" :editMode="editMode")
    product-info-availability(v-if="page == 'availability'" :data="data" :editMode="editMode")
    product-info-pricing(v-if="page == 'pricing'" :data="data" :editMode="editMode")
</template>

<script>
import ProductInfoSummary from 'components/cabinet/ecommerce/general/seller_product_summary'
import ProductInfoAvailability from 'components/cabinet/ecommerce/general/seller_product_availability'
import ProductInfoPricing from 'components/cabinet/ecommerce/general/seller_product_pricing'

export default {
  name: 'product-info',
  props: {
    data: {type: Object},
	editMode: {type: Boolean, default: false},
  },
  
  data (){return {
	  page: 'summary',
  }},
  
  
  components: {
	  'product-info-summary': ProductInfoSummary,
	  'product-info-availability': ProductInfoAvailability,
	  'product-info-pricing': ProductInfoPricing,
  },
  
  
  // methods: {
  // },
  // 
  // 
  // created (){
  // },
  // 
  // 
  // computed: {
  // },
  
}
</script>