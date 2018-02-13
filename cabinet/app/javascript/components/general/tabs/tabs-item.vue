<template>
  <div v-show="isActive"><slot></slot></div>
</template>

<script>

export default {
  name: 'tab-item',
  props: {
    title: {type: String, required: true},
    selected: {type: Boolean, default: false}
  },
  
  data (){return {
	   isActive: false,
  }},
  
  
  methods: {
  },
  
  
  computed: {
    href() {
      return '#' + this.title.toLowerCase().replace(/ /g , '-')
    }
  },
  
  mounted() {
    this.isActive = this.selected
  },
  
}

</script>