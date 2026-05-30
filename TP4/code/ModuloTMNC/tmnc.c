#include <linux/module.h>
#include <linux/kernel.h>
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Modulo TMNC");
MODULE_AUTHOR("TeamMergeNoConflict");

int modulo_lin_init(void)
{
	printk(KERN_INFO "TMNC saluda desde kernel!!\n");
	return 0;
}

void modulo_lin_clean(void)
{
	printk(KERN_INFO "TMNC se despide del kernel :(\n");
}

module_init(modulo_lin_init);
module_exit(modulo_lin_clean);
