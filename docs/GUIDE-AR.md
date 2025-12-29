# دليل إعداد بيئة العمل المتزامنة بين الأجهزة

## نظرة عامة

هذا الدليل يشرح كيفية إعداد بيئة عمل متزامنة بين جهازين:
- **جهاز المنزل:** Windows مع WSL (Ubuntu)
- **جهاز اللابتوب:** macOS

### المكونات الرئيسية

| المكون | الوظيفة |
|--------|---------|
| **GitHub** | مصدر الحقيقة المركزي لجميع المشاريع |
| **Dotfiles** | ملفات الإعدادات المشتركة بين الأجهزة |
| **handoff / pickup** | أوامر مخصصة لمزامنة العمل |
| **GPG + pass** | إدارة كلمات المرور والأسرار |
| **GitHub Actions** | تشغيل الاختبارات تلقائياً عند كل push |

---

## هيكل مجلد Dotfiles

```
~/dotfiles/
├── install.sh                  # المثبت الرئيسي (يكتشف نظام التشغيل)
├── bash/
│   └── .bashrc                 # إعدادات WSL
├── zsh/
│   └── .zshrc                  # إعدادات Mac
├── shared/
│   ├── .gitconfig              # إعدادات Git (مشتركة)
│   ├── .aliases                # الاختصارات المشتركة
│   └── .tool-versions.example  # مثال لإصدارات الأدوات
├── bin/
│   ├── handoff                 # أمر المغادرة
│   ├── pickup                  # أمر الوصول
│   └── migrate-project         # أمر تهيئة المشاريع
├── config/
│   └── handoff/
│       └── projects.example    # مثال لقائمة المشاريع
├── github/
│   ├── .gitattributes.template # قالب لإعدادات نهايات الأسطر
│   ├── .env.template.example   # مثال لملف المتغيرات
│   └── workflows/
│       ├── test.yml.template   # قالب CI عام
│       └── python-test.yml     # قالب CI لـ Python
└── gpg-export/
    ├── .gitignore              # منع رفع المفاتيح
    └── README.md               # تعليمات نقل المفاتيح
```

---

## الأوامر المخصصة

### أمر `handoff` - قبل مغادرة الجهاز

يقوم هذا الأمر بـ:
1. فحص جميع المشاريع المسجلة
2. حفظ التغييرات غير المحفوظة (WIP commit)
3. رفع جميع التغييرات إلى GitHub

```bash
# تشغيل الأمر
handoff

# معاينة بدون تنفيذ
handoff --dry-run

# عرض الحالة فقط
handoff --status

# إدارة المشاريع
handoff add ~/projects/my-project    # إضافة مشروع
handoff remove ~/projects/old-one    # إزالة مشروع
handoff list                         # عرض المشاريع
```

**مثال على المخرجات:**
```
🔄 Handoff starting...

[1/3] ~/projects/project-a
      Branch: feature/login
      Status: 2 uncommitted files
      → Committed: "WIP: handoff from wsl"
      → Pushed to origin/feature/login
      ✓ Done

[2/3] ~/projects/project-b
      Branch: main
      Status: Clean
      ✓ Already up to date

────────────────────────────
Handoff complete.
Safe to switch machines.
```

### أمر `pickup` - عند الوصول للجهاز

يقوم هذا الأمر بـ:
1. سحب آخر التغييرات من GitHub
2. تثبيت التبعيات إذا لزم الأمر (npm, pip, etc.)

```bash
# تشغيل الأمر
pickup

# تخطي تثبيت التبعيات
pickup --skip-install

# عرض الحالة فقط
pickup --status
```

### أمر `migrate-project` - تهيئة مشروع قائم

يقوم هذا الأمر بإضافة:
- `.gitattributes` - لإصلاح مشاكل نهايات الأسطر
- `.gitignore` - لتجاهل الملفات غير المطلوبة
- `.github/workflows/test.yml` - لتشغيل الاختبارات
- `.tool-versions` - لتحديد إصدارات الأدوات
- `.env.template` - لتوثيق المتغيرات المطلوبة

```bash
cd ~/projects/my-python-project
migrate-project
```

---

## إدارة كلمات المرور (pass)

### الأوامر الأساسية

```bash
# إضافة سر جديد
pass insert project/DATABASE_URL

# إضافة سر متعدد الأسطر
pass insert -m project/API_KEYS

# عرض سر
pass project/DATABASE_URL

# نسخ إلى الحافظة
pass -c project/DATABASE_URL

# عرض جميع الأسرار
pass

# حذف سر
pass rm project/OLD_SECRET

# مزامنة مع GitHub
pass git push
pass git pull
```

### هيكل تنظيم الأسرار المقترح

```
Password Store
├── projects/
│   ├── project-a/
│   │   ├── DATABASE_URL
│   │   ├── API_KEY
│   │   └── SECRET_KEY
│   └── project-b/
│       └── STRIPE_KEY
├── services/
│   ├── aws/
│   ├── digitalocean/
│   └── cloudflare/
└── personal/
    └── github-token
```

### استخدام الأسرار في المشاريع

```bash
# إنشاء ملف .env من الأسرار
pass projects/my-app/DATABASE_URL > .env
pass projects/my-app/API_KEY >> .env

# أو استخدام سكربت
#!/bin/bash
echo "DATABASE_URL=$(pass projects/my-app/DATABASE_URL)" > .env
echo "API_KEY=$(pass projects/my-app/API_KEY)" >> .env
```

---

## سير العمل اليومي

### عند بدء العمل (الوصول للجهاز)

```bash
# 1. سحب آخر التغييرات
pickup

# 2. الانتقال للمشروع
cd ~/projects/my-project

# 3. التأكد من الفرع الصحيح
git branch

# 4. بدء العمل
code .
```

### أثناء العمل

```bash
# إنشاء فرع جديد للميزة
git checkout -b feature/new-feature

# حفظ التغييرات
git add .
git commit -m "وصف التغييرات"

# رفع التغييرات
git push
```

### عند انتهاء العمل (مغادرة الجهاز)

```bash
# أمر واحد يفعل كل شيء
handoff
```

---

## إعداد جهاز Mac (الجهاز الثاني)

### 1. تثبيت الأدوات الأساسية

```bash
# تثبيت Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# تثبيت الأدوات
brew install git gnupg pass gh

# تثبيت mise (مدير إصدارات الأدوات)
brew install mise
```

### 2. تسجيل الدخول لـ GitHub

```bash
gh auth login
```

### 3. استنساخ Dotfiles

```bash
git clone https://github.com/rwadalebsar/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
source ~/.zshrc
```

### 4. نقل مفاتيح GPG

**الخيار 1: عبر USB**
1. انسخ الملفات من WSL إلى USB:
   - `~/dotfiles/gpg-export/public.key`
   - `~/dotfiles/gpg-export/private.key`
2. انسخها إلى Mac في `~/dotfiles/gpg-export/`

**الخيار 2: عبر الشبكة المحلية**
```bash
# من Mac (استبدل WSL-IP بعنوان IP الخاص بـ WSL)
scp user@WSL-IP:~/dotfiles/gpg-export/*.key ~/dotfiles/gpg-export/
```

### 5. استيراد مفاتيح GPG

```bash
# استيراد المفتاح العام
gpg --import ~/dotfiles/gpg-export/public.key

# استيراد المفتاح الخاص (يتطلب كلمة المرور)
gpg --import ~/dotfiles/gpg-export/private.key

# الوثوق بالمفتاح
gpg --edit-key E68B63B4
# اكتب: trust
# اختر: 5 (ultimate trust)
# اكتب: quit

# التحقق
gpg --list-keys
```

### 6. استنساخ مخزن كلمات المرور

```bash
git clone https://github.com/rwadalebsar/pass-store.git ~/.password-store
```

### 7. تسجيل المشاريع

```bash
handoff add ~/dotfiles
handoff add ~/.password-store
```

### 8. حذف ملفات المفاتيح

```bash
rm ~/dotfiles/gpg-export/*.key
```

### 9. استنساخ المشاريع

```bash
mkdir -p ~/projects
cd ~/projects
gh repo clone rwadalebsar/project-name
handoff add ~/projects/project-name
```

---

## تهيئة مشروع جديد

### 1. إنشاء المشروع

```bash
mkdir ~/projects/new-project
cd ~/projects/new-project
git init
```

### 2. تهيئة المشروع للعمل المتزامن

```bash
migrate-project
```

### 3. مراجعة التغييرات

```bash
git diff --cached
```

### 4. الحفظ والرفع

```bash
git commit -m "Initial project setup with CI"
gh repo create new-project --public --source=. --push
```

### 5. التسجيل في handoff

```bash
handoff add ~/projects/new-project
```

---

## تهيئة مشروع قائم (على Mac)

### 1. الانتقال للمشروع

```bash
cd ~/projects/existing-project
```

### 2. تشغيل التهيئة

```bash
migrate-project
```

### 3. مراجعة وحفظ

```bash
git diff --cached
git commit -m "Add CI workflow and cross-platform support"
```

### 4. إنشاء مستودع GitHub

```bash
gh repo create existing-project --public --source=. --push
```

### 5. التسجيل

```bash
handoff add ~/projects/existing-project
```

---

## GitHub Actions

### كيف يعمل

عند كل `git push`:
1. GitHub يستقبل الكود
2. GitHub Actions يشغل الاختبارات
3. تظهر النتيجة ✅ أو ❌

### عرض نتائج الاختبارات

```bash
# عبر سطر الأوامر
gh run list
gh run view

# أو عبر الموقع
# https://github.com/rwadalebsar/project-name/actions
```

### تخصيص الاختبارات

عدّل ملف `.github/workflows/test.yml` في مشروعك:

```yaml
- name: Run tests
  run: |
    pytest                    # Python
    npm test                  # Node.js
    go test ./...            # Go
```

---

## حل المشاكل الشائعة

### مشكلة: "GPG cannot sign data"

```bash
# تأكد من وجود المفتاح
gpg --list-secret-keys

# أعد تشغيل GPG agent
gpgconf --kill gpg-agent
```

### مشكلة: "pass: encryption failed"

```bash
# تحقق من صحة GPG ID
cat ~/.password-store/.gpg-id

# أعد التهيئة إذا لزم الأمر
pass init E68B63B4
```

### مشكلة: تعارض عند السحب

```bash
# عرض الملفات المتعارضة
git status

# حل التعارض يدوياً ثم
git add .
git commit -m "Resolve merge conflict"
```

### مشكلة: نسيت عمل handoff

إذا نسيت رفع التغييرات قبل المغادرة:
1. التغييرات موجودة فقط على الجهاز القديم
2. عند العودة للجهاز القديم، شغّل `handoff`
3. ثم على الجهاز الجديد، شغّل `pickup`

---

## الروابط المهمة

| المورد | الرابط |
|--------|--------|
| Dotfiles | https://github.com/rwadalebsar/dotfiles |
| Pass Store | https://github.com/rwadalebsar/pass-store (خاص) |

---

## ملخص الأوامر

| الأمر | الوظيفة |
|-------|---------|
| `handoff` | مزامنة ورفع قبل المغادرة |
| `pickup` | سحب وتحديث عند الوصول |
| `handoff list` | عرض المشاريع المسجلة |
| `handoff add PATH` | إضافة مشروع |
| `migrate-project` | تهيئة مشروع للعمل المتزامن |
| `pass` | عرض الأسرار |
| `pass insert NAME` | إضافة سر |
| `pass NAME` | عرض سر |
| `pass git push` | مزامنة الأسرار |

---

## الخطوات السريعة

### مغادرة الجهاز
```bash
handoff
```

### الوصول للجهاز
```bash
pickup
```

### إضافة مشروع جديد
```bash
cd ~/projects/new-project
migrate-project
git commit -m "Setup"
gh repo create --public --source=. --push
handoff add .
```

---

تم إعداد هذا الدليل بتاريخ: ديسمبر 2025
