#include <linux/module.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/uaccess.h>
#include <linux/jiffies.h> 

#define DEVICE_NAME "TeamMergeNoConflict"
#define CLASS_NAME "teammergenoconflict_class"

static dev_t dev;
static struct cdev c_dev;
static struct class *cl;
static char curr_signal = '1'; 

static int my_open(struct inode *i, struct file *f)
{
    printk(KERN_INFO "TeamMergeNoConflict: open()\n");
    return 0;
}

static int my_close(struct inode *i, struct file *f)
{
    printk(KERN_INFO "TeamMergeNoConflict: close()\n");
    return 0;
}

static ssize_t my_read(struct file *f, char __user *buf, size_t len, loff_t *off)
{
    char val;

    if (curr_signal == '1') {
        val = ((jiffies / HZ) % 2) ? '1' : '0';
    } else if (curr_signal == '2') {
        val = ((jiffies / (HZ / 2)) % 2) ? '1' : '0';
    } else {
        return -EINVAL;
    }

    return simple_read_from_buffer(buf, len, off, &val, 1);
}

static ssize_t my_write(struct file *f, const char __user *buf, size_t len, loff_t *off)
{
    char kbuf[2] = {0};
    ssize_t ret;

    ret = simple_write_to_buffer(kbuf, sizeof(kbuf) - 1, off, buf, len);
    if (ret < 0)
        return ret;

    if (kbuf[0] != '1' && kbuf[0] != '2')
        return -EINVAL;

    curr_signal = kbuf[0];
    return ret;
}

static struct file_operations dev_fops = {
    .owner = THIS_MODULE,
    .open = my_open,
    .release = my_close,
    .read = my_read,
    .write = my_write
};

static int __init teammergenoconflict_init(void)
{
    int ret;
    dev_t dev_no;
    struct device *dev_ret;

    if ((ret = alloc_chrdev_region(&dev_no, 0, 1, DEVICE_NAME))) {
        pr_err("TeamMergeNoConflict: Failed to allocate major number\n");
        return ret;
    }
    dev = MKDEV(MAJOR(dev_no), 0);

    cdev_init(&c_dev, &dev_fops);
    if ((ret = cdev_add(&c_dev, dev, 1))) {
        pr_err("TeamMergeNoConflict: Failed to add character device\n");
        goto fail_cdev;
    }

    cl = class_create(THIS_MODULE, CLASS_NAME);
    if (IS_ERR(cl)) {
        ret = PTR_ERR(cl);
        pr_err("TeamMergeNoConflict: Failed to create device class\n");
        goto fail_class;
    }

    dev_ret = device_create(cl, NULL, dev, NULL, DEVICE_NAME);
    if (IS_ERR(dev_ret)) {
        ret = PTR_ERR(dev_ret);
        pr_err("TeamMergeNoConflict: Failed to create device\n");
        goto fail_device;
    }

    pr_info("TeamMergeNoConflict: Module initialized successfully in QEMU mode\n");
    return 0;

fail_device:
    class_destroy(cl);
fail_class:
    cdev_del(&c_dev);
fail_cdev:
    unregister_chrdev_region(dev, 1);
    return ret;
}

static void __exit teammergenoconflict_exit(void)
{
    device_destroy(cl, dev);
    class_destroy(cl);
    cdev_del(&c_dev);
    unregister_chrdev_region(dev, 1);
    pr_info("TeamMergeNoConflict: Module unloaded successfully\n");
}

module_init(teammergenoconflict_init);
module_exit(teammergenoconflict_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Grupo TeamMergeNoConflict - Sistemas de computacion");
MODULE_DESCRIPTION("Driver virtualizado para lectura simulada en QEMU");