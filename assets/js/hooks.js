let Hooks = {};

Hooks.SelectAllPermissions = {
  mounted() {
    this.el.addEventListener("change", (event) => {
      const groupId = this.el.dataset.groupId;
      const isChecked = event.target.checked;
      const checkboxes = document.querySelectorAll(
        `#access-group-permissions-${groupId} .permission-checkbox`
      );
      checkboxes.forEach((checkbox) => {
        checkbox.checked = isChecked;
      });
    });
  }
};

Hooks.SelectResourcePermissions = {
  mounted() {
    this.el.addEventListener("change", (event) => {
      const resource = this.el.dataset.resource;
      const groupId = this.el.dataset.groupId;
      const isChecked = event.target.checked;
      const checkboxes = document.querySelectorAll(
        `#access-group-permissions-${groupId} .permission-checkbox[data-resource="${resource}"]`
      );
      checkboxes.forEach((checkbox) => {
        checkbox.checked = isChecked;
      });
    });
  }
};

export default Hooks;