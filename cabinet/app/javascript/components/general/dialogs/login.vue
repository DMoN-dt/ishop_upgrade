<template>
  <div class="message-wrapper" @click.self="$close()">
    <form class="message-content login confirm" @submit.prevent="submit">
      <div class="message-title">Доступ в Личный кабинет</div>
      <div class="message-text">
        <input class="md-textfield" type="text" placeholder="Логин (E-mail)" v-model="user.username">
        <input class="md-textfield" type="password" placeholder="Пароль" v-model="user.password">
      </div>
      <div class="buttons">
        <button class="md-button flat" type="button" @click="$close()">Отмена</button>
        <button class="md-button flat" type="submit">Войти</button>
      </div>
    </form>
  </div>
</template>

<script>
  // import { messageBoxDlg } from '../dialogs'

  export default {
    data: () => ({
      user: {
        username: '',
        password: ''
      }
    }),
    methods: {
      submit () {
        if (this.user.username.trim() && this.user.password) {
          // You can close dialogs with a promise.
          // The caller will receive the final result of this promise.
          this.$close({
            username: this.user.username.trim(),
            password: this.user.password
          })
        } else {
          messageBox('? Пожалуйста укажите свой Логин и Пароль для продолжения работы.')
        }
      }
    }
  }
</script>