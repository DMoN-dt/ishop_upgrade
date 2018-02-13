<template>
  <div>
    <div :class="classes">
      <ul class="tabs-titles">
        <li v-for="tab in tabs" :class="{ 'is-active': tab.isActive }">
          <a v-if="urlTitles" class="title" :href="tab.href" @click="selectTab(tab)">{{ tab.title }}</a>
          <span v-else class="title" @click="selectTab(tab)">{{ tab.title }}</span>
        </li>
      </ul>
    </div>
    <div class="tabs-details"><slot></slot></div>
  </div>
</template>

<script>

export default {
  name: 'tabs',
  props: {
    urlTitles: {type: Boolean, default: false},
	klass: {type: String}
  },
  
  data (){return {
	  tabs: [],
  }},

  methods: {
	selectTab: function(selectedTab) {
      this.tabs.forEach(tab => {
        tab.isActive = (tab.title == selectedTab.title);
      });
    }
  },
  
  created() {
    this.tabs = this.$children
  },

  computed: {
	classes() {
		return [
			{'tabs': true},
			{[this.klass]: !!this.klass},
		]
	}
  },
  
}

</script>