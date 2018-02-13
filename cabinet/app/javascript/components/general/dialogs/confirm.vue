<template>
  <div class="message-wrapper" @click.self="cancel">
    <div class="message-content confirm">
      <div class="message-title">{{ title }}</div>
      <div class="message-text">{{ content }}</div>
      <div class="message-text" v-if="question">{{ question }}</div>
      <div class="buttons">
        <button class="btn btn-primary rmargin-05" @click="ok">{{ btn_OK_text }}</button>
		<button class="btn btn-success rmargin-05" @click="no" v-if="btn_yes_no || btn_yes_no_cancel">{{ btn_No_text }}</button>
		<button class="btn btn-secondary" @click="cancel" v-if="btn_ok_cancel || btn_yes_no_cancel">{{ btn_Cancel_text }}</button>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: {
      title: String,
      content: String,
      question: String,
	  
      btn_yes: String,
      btn_no: String,
      btn_cancel: String,
	  
	  btn_yes_no: Boolean,
      btn_ok_cancel: Boolean,
      btn_yes_no_cancel: Boolean,
    },
    methods: {
      ok () {
        // Close confirm dialog and send 'true' to its caller
        this.$close(true)
      },
      no () {
        this.$close(null)
      },
	  cancel () {
        this.$close(false)
      }
    },
	computed: {
		btn_OK_text (){
			if(this.btn_yes)return this.btn_yes;
			if(this.btn_yes_no || this.btn_yes_no_cancel)return this.$t("buttons.Yes");
			return this.$t("buttons.OK")
		},
		
		btn_No_text (){
			if(this.btn_no)return this.btn_no;
			if(this.btn_yes_no || this.btn_yes_no_cancel)return this.$t("buttons.No");
			return null
		},
		
		btn_Cancel_text (){
			if(this.btn_cancel)return this.btn_cancel;
			return this.$t("buttons.Cancel")
		}
	}
  }
</script>