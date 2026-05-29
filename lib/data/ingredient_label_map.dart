/// Maps ML Kit image labels → pantry ingredient names (English + Urdu).
/// Categories: Vegetable, Fruit, Protein, Dairy, Grain, Lentil,
///             Spice, Herb, Oil & Fat, Condiment, Nut & Dry Fruit, Sweetener, Beverage
class IngredientHint {
  final String nameEn;
  final String nameUr;
  final String category;
  final String icon;

  const IngredientHint(this.nameEn, this.nameUr, this.category, this.icon);
}

class IngredientLabelMap {
  // ─── 200 + entries covering every common ML Kit label ─────────────────────
  static const Map<String, IngredientHint> _map = {

    // ── VEGETABLES ──────────────────────────────────────────────────────────
    'tomato':           IngredientHint('Tomato',        'Tamatar',       'Vegetable',     '🍅'),
    'tomatoes':         IngredientHint('Tomato',        'Tamatar',       'Vegetable',     '🍅'),
    'cherry tomato':    IngredientHint('Tomato',        'Tamatar',       'Vegetable',     '🍅'),
    'roma tomato':      IngredientHint('Tomato',        'Tamatar',       'Vegetable',     '🍅'),
    'onion':            IngredientHint('Onion',         'Pyaz',          'Vegetable',     '🧅'),
    'onions':           IngredientHint('Onion',         'Pyaz',          'Vegetable',     '🧅'),
    'red onion':        IngredientHint('Onion',         'Pyaz',          'Vegetable',     '🧅'),
    'shallot':          IngredientHint('Onion',         'Pyaz',          'Vegetable',     '🧅'),
    'spring onion':     IngredientHint('Spring Onion',  'Hara Pyaz',     'Vegetable',     '🌱'),
    'green onion':      IngredientHint('Spring Onion',  'Hara Pyaz',     'Vegetable',     '🌱'),
    'scallion':         IngredientHint('Spring Onion',  'Hara Pyaz',     'Vegetable',     '🌱'),
    'chive':            IngredientHint('Spring Onion',  'Hara Pyaz',     'Vegetable',     '🌱'),
    'potato':           IngredientHint('Potato',        'Aloo',          'Vegetable',     '🥔'),
    'potatoes':         IngredientHint('Potato',        'Aloo',          'Vegetable',     '🥔'),
    'sweet potato':     IngredientHint('Sweet Potato',  'Shakarkandi',   'Vegetable',     '🍠'),
    'yam':              IngredientHint('Sweet Potato',  'Shakarkandi',   'Vegetable',     '🍠'),
    'carrot':           IngredientHint('Carrot',        'Gajar',         'Vegetable',     '🥕'),
    'carrots':          IngredientHint('Carrot',        'Gajar',         'Vegetable',     '🥕'),
    'spinach':          IngredientHint('Spinach',       'Palak',         'Vegetable',     '🥬'),
    'kale':             IngredientHint('Spinach',       'Palak',         'Vegetable',     '🥬'),
    'swiss chard':      IngredientHint('Spinach',       'Palak',         'Vegetable',     '🥬'),
    'lettuce':          IngredientHint('Lettuce',       'Salad Patta',   'Vegetable',     '🥬'),
    'cabbage':          IngredientHint('Cabbage',       'Band Gobi',     'Vegetable',     '🥬'),
    'cauliflower':      IngredientHint('Cauliflower',   'Phool Gobi',    'Vegetable',     '🥦'),
    'broccoli':         IngredientHint('Broccoli',      'Hari Gobi',     'Vegetable',     '🥦'),
    'eggplant':         IngredientHint('Eggplant',      'Baingan',       'Vegetable',     '🍆'),
    'aubergine':        IngredientHint('Eggplant',      'Baingan',       'Vegetable',     '🍆'),
    'brinjal':          IngredientHint('Eggplant',      'Baingan',       'Vegetable',     '🍆'),
    'pumpkin':          IngredientHint('Pumpkin',       'Kaddu',         'Vegetable',     '🎃'),
    'squash':           IngredientHint('Pumpkin',       'Kaddu',         'Vegetable',     '🎃'),
    'butternut':        IngredientHint('Pumpkin',       'Kaddu',         'Vegetable',     '🎃'),
    'zucchini':         IngredientHint('Zucchini',      'Tori',          'Vegetable',     '🥒'),
    'courgette':        IngredientHint('Zucchini',      'Tori',          'Vegetable',     '🥒'),
    'cucumber':         IngredientHint('Cucumber',      'Kheera',        'Vegetable',     '🥒'),
    'radish':           IngredientHint('Radish',        'Mooli',         'Vegetable',     '🌱'),
    'turnip':           IngredientHint('Turnip',        'Shalgam',       'Vegetable',     '🌱'),
    'beetroot':         IngredientHint('Beetroot',      'Chukandar',     'Vegetable',     '🟣'),
    'beet':             IngredientHint('Beetroot',      'Chukandar',     'Vegetable',     '🟣'),
    'peas':             IngredientHint('Peas',          'Matar',         'Vegetable',     '🫛'),
    'green peas':       IngredientHint('Peas',          'Matar',         'Vegetable',     '🫛'),
    'snap pea':         IngredientHint('Peas',          'Matar',         'Vegetable',     '🫛'),
    'okra':             IngredientHint('Okra',          'Bhindi',        'Vegetable',     '🌿'),
    'ladyfinger':       IngredientHint('Okra',          'Bhindi',        'Vegetable',     '🌿'),
    'lady finger':      IngredientHint('Okra',          'Bhindi',        'Vegetable',     '🌿'),
    'bitter gourd':     IngredientHint('Bitter Gourd',  'Karela',        'Vegetable',     '🌿'),
    'bitter melon':     IngredientHint('Bitter Gourd',  'Karela',        'Vegetable',     '🌿'),
    'bottle gourd':     IngredientHint('Bottle Gourd',  'Lauki',         'Vegetable',     '🌿'),
    'lauki':            IngredientHint('Bottle Gourd',  'Lauki',         'Vegetable',     '🌿'),
    'corn':             IngredientHint('Corn',          'Makka',         'Vegetable',     '🌽'),
    'maize':            IngredientHint('Corn',          'Makka',         'Vegetable',     '🌽'),
    'sweet corn':       IngredientHint('Corn',          'Makka',         'Vegetable',     '🌽'),
    'mushroom':         IngredientHint('Mushroom',      'Mushroom',      'Vegetable',     '🍄'),
    'mushrooms':        IngredientHint('Mushroom',      'Mushroom',      'Vegetable',     '🍄'),
    'bell pepper':      IngredientHint('Bell Pepper',   'Shimla Mirch',  'Vegetable',     '🫑'),
    'capsicum':         IngredientHint('Bell Pepper',   'Shimla Mirch',  'Vegetable',     '🫑'),
    'leek':             IngredientHint('Leek',          'Leek',          'Vegetable',     '🌱'),
    'celery':           IngredientHint('Celery',        'Ajwain Patta',  'Vegetable',     '🌿'),
    'asparagus':        IngredientHint('Asparagus',     'Asparagus',     'Vegetable',     '🌿'),
    'artichoke':        IngredientHint('Artichoke',     'Artichoke',     'Vegetable',     '🌿'),
    'produce':          IngredientHint('Mixed Vegetables','Sabzi Mix',   'Vegetable',     '🥬'),

    // ── FRUITS ──────────────────────────────────────────────────────────────
    'lemon':            IngredientHint('Lemon',         'Nimbu',         'Fruit',         '🍋'),
    'lime':             IngredientHint('Lemon',         'Nimbu',         'Fruit',         '🍋'),
    'citrus':           IngredientHint('Lemon',         'Nimbu',         'Fruit',         '🍋'),
    'orange':           IngredientHint('Orange',        'Narangi',       'Fruit',         '🍊'),
    'tangerine':        IngredientHint('Orange',        'Narangi',       'Fruit',         '🍊'),
    'clementine':       IngredientHint('Orange',        'Narangi',       'Fruit',         '🍊'),
    'apple':            IngredientHint('Apple',         'Seb',           'Fruit',         '🍎'),
    'apples':           IngredientHint('Apple',         'Seb',           'Fruit',         '🍎'),
    'banana':           IngredientHint('Banana',        'Kela',          'Fruit',         '🍌'),
    'bananas':          IngredientHint('Banana',        'Kela',          'Fruit',         '🍌'),
    'mango':            IngredientHint('Mango',         'Aam',           'Fruit',         '🥭'),
    'mangoes':          IngredientHint('Mango',         'Aam',           'Fruit',         '🥭'),
    'grapes':           IngredientHint('Grapes',        'Angoor',        'Fruit',         '🍇'),
    'grape':            IngredientHint('Grapes',        'Angoor',        'Fruit',         '🍇'),
    'strawberry':       IngredientHint('Strawberry',    'Strawberry',    'Fruit',         '🍓'),
    'strawberries':     IngredientHint('Strawberry',    'Strawberry',    'Fruit',         '🍓'),
    'peach':            IngredientHint('Peach',         'Aaru',          'Fruit',         '🍑'),
    'pear':             IngredientHint('Pear',          'Nashpati',      'Fruit',         '🍐'),
    'plum':             IngredientHint('Plum',          'Aloo Bukhara',  'Fruit',         '🍑'),
    'pomegranate':      IngredientHint('Pomegranate',   'Anar',          'Fruit',         '🍎'),
    'watermelon':       IngredientHint('Watermelon',    'Tarbuz',        'Fruit',         '🍉'),
    'melon':            IngredientHint('Melon',         'Kharbooza',     'Fruit',         '🍈'),
    'guava':            IngredientHint('Guava',         'Amrood',        'Fruit',         '🍈'),
    'papaya':           IngredientHint('Papaya',        'Papita',        'Fruit',         '🍈'),
    'pineapple':        IngredientHint('Pineapple',     'Ananas',        'Fruit',         '🍍'),
    'coconut':          IngredientHint('Coconut',       'Nariyal',       'Fruit',         '🥥'),
    'fig':              IngredientHint('Fig',           'Anjeer',        'Fruit',         '🍈'),
    'apricot':          IngredientHint('Apricot',       'Khumani',       'Fruit',         '🍑'),
    'cherry':           IngredientHint('Cherry',        'Cherry',        'Fruit',         '🍒'),
    'kiwi':             IngredientHint('Kiwi',          'Kiwi',          'Fruit',         '🥝'),
    'fruit':            IngredientHint('Mixed Fruit',   'Phal',          'Fruit',         '🍎'),

    // ── PROTEIN ─────────────────────────────────────────────────────────────
    'chicken':          IngredientHint('Chicken',       'Murgh',         'Protein',       '🍗'),
    'poultry':          IngredientHint('Chicken',       'Murgh',         'Protein',       '🍗'),
    'hen':              IngredientHint('Chicken',       'Murgh',         'Protein',       '🍗'),
    'turkey':           IngredientHint('Chicken',       'Murgh',         'Protein',       '🍗'),
    'duck':             IngredientHint('Chicken',       'Murgh',         'Protein',       '🍗'),
    'meat':             IngredientHint('Mutton',        'Gosht',         'Protein',       '🥩'),
    'mutton':           IngredientHint('Mutton',        'Gosht',         'Protein',       '🥩'),
    'lamb':             IngredientHint('Mutton',        'Gosht',         'Protein',       '🥩'),
    'beef':             IngredientHint('Beef',          'Beef',          'Protein',       '🥩'),
    'steak':            IngredientHint('Beef',          'Beef',          'Protein',       '🥩'),
    'pork':             IngredientHint('Beef',          'Beef',          'Protein',       '🥩'),
    'minced meat':      IngredientHint('Mince',         'Qeema',         'Protein',       '🥩'),
    'ground meat':      IngredientHint('Mince',         'Qeema',         'Protein',       '🥩'),
    'ground beef':      IngredientHint('Mince',         'Qeema',         'Protein',       '🥩'),
    'fish':             IngredientHint('Fish',          'Machli',        'Protein',       '🐟'),
    'seafood':          IngredientHint('Fish',          'Machli',        'Protein',       '🐟'),
    'salmon':           IngredientHint('Fish',          'Machli',        'Protein',       '🐟'),
    'tuna':             IngredientHint('Fish',          'Machli',        'Protein',       '🐟'),
    'tilapia':          IngredientHint('Fish',          'Machli',        'Protein',       '🐟'),
    'shrimp':           IngredientHint('Shrimp',        'Jhinga',        'Protein',       '🦐'),
    'prawn':            IngredientHint('Shrimp',        'Jhinga',        'Protein',       '🦐'),
    'crab':             IngredientHint('Crab',          'Kekda',         'Protein',       '🦀'),
    'egg':              IngredientHint('Eggs',          'Anday',         'Protein',       '🥚'),
    'eggs':             IngredientHint('Eggs',          'Anday',         'Protein',       '🥚'),
    'egg yolk':         IngredientHint('Eggs',          'Anday',         'Protein',       '🥚'),

    // ── DAIRY ───────────────────────────────────────────────────────────────
    'milk':             IngredientHint('Milk',          'Doodh',         'Dairy',         '🥛'),
    'whole milk':       IngredientHint('Milk',          'Doodh',         'Dairy',         '🥛'),
    'yogurt':           IngredientHint('Yogurt',        'Dahi',          'Dairy',         '🥛'),
    'yoghurt':          IngredientHint('Yogurt',        'Dahi',          'Dairy',         '🥛'),
    'curd':             IngredientHint('Yogurt',        'Dahi',          'Dairy',         '🥛'),
    'butter':           IngredientHint('Butter',        'Makhan',        'Dairy',         '🧈'),
    'cream':            IngredientHint('Cream',         'Malai',         'Dairy',         '🥛'),
    'heavy cream':      IngredientHint('Cream',         'Malai',         'Dairy',         '🥛'),
    'sour cream':       IngredientHint('Cream',         'Malai',         'Dairy',         '🥛'),
    'cheese':           IngredientHint('Cheese',        'Paneer',        'Dairy',         '🧀'),
    'paneer':           IngredientHint('Paneer',        'Paneer',        'Dairy',         '🧀'),
    'mozzarella':       IngredientHint('Cheese',        'Paneer',        'Dairy',         '🧀'),
    'cheddar':          IngredientHint('Cheese',        'Paneer',        'Dairy',         '🧀'),
    'condensed milk':   IngredientHint('Condensed Milk','Mawa',          'Dairy',         '🥛'),
    'khoya':            IngredientHint('Khoya',         'Khoya/Mawa',    'Dairy',         '🥛'),
    'dairy':            IngredientHint('Milk',          'Doodh',         'Dairy',         '🥛'),

    // ── GRAINS & STAPLES ────────────────────────────────────────────────────
    'rice':             IngredientHint('Basmati Rice',  'Chawal',        'Grain',         '🍚'),
    'basmati':          IngredientHint('Basmati Rice',  'Chawal',        'Grain',         '🍚'),
    'white rice':       IngredientHint('Basmati Rice',  'Chawal',        'Grain',         '🍚'),
    'brown rice':       IngredientHint('Brown Rice',    'Bhoora Chawal', 'Grain',         '🍚'),
    'fried rice':       IngredientHint('Basmati Rice',  'Chawal',        'Grain',         '🍚'),
    'flour':            IngredientHint('Atta',          'Atta',          'Grain',         '🌾'),
    'wheat':            IngredientHint('Atta',          'Atta',          'Grain',         '🌾'),
    'wheat flour':      IngredientHint('Atta',          'Atta',          'Grain',         '🌾'),
    'whole wheat':      IngredientHint('Atta',          'Atta',          'Grain',         '🌾'),
    'maida':            IngredientHint('Maida',         'Maida',         'Grain',         '🌾'),
    'all purpose flour':IngredientHint('Maida',         'Maida',         'Grain',         '🌾'),
    'refined flour':    IngredientHint('Maida',         'Maida',         'Grain',         '🌾'),
    'semolina':         IngredientHint('Semolina',      'Suji',          'Grain',         '🌾'),
    'oats':             IngredientHint('Oats',          'Oats',          'Grain',         '🌾'),
    'bread':            IngredientHint('Bread',         'Bread/Roti',    'Grain',         '🍞'),
    'naan':             IngredientHint('Naan',          'Naan',          'Grain',         '🫓'),
    'roti':             IngredientHint('Roti',          'Roti',          'Grain',         '🫓'),
    'pita':             IngredientHint('Roti',          'Roti',          'Grain',         '🫓'),
    'flatbread':        IngredientHint('Roti',          'Roti',          'Grain',         '🫓'),
    'tortilla':         IngredientHint('Roti',          'Roti',          'Grain',         '🫓'),
    'cornmeal':         IngredientHint('Corn Flour',    'Makki Atta',    'Grain',         '🌽'),
    'corn flour':       IngredientHint('Corn Flour',    'Makki Atta',    'Grain',         '🌽'),
    'barley':           IngredientHint('Barley',        'Jau',           'Grain',         '🌾'),
    'pasta':            IngredientHint('Pasta',         'Pasta',         'Grain',         '🍝'),
    'noodle':           IngredientHint('Noodles',       'Noodles',       'Grain',         '🍜'),
    'noodles':          IngredientHint('Noodles',       'Noodles',       'Grain',         '🍜'),
    'vermicelli':       IngredientHint('Vermicelli',    'Seviyan',       'Grain',         '🌾'),
    'spaghetti':        IngredientHint('Pasta',         'Pasta',         'Grain',         '🍝'),
    'grain':            IngredientHint('Basmati Rice',  'Anaj',          'Grain',         '🌾'),

    // ── LENTILS & LEGUMES ───────────────────────────────────────────────────
    'lentil':           IngredientHint('Masoor Daal',   'Masoor Daal',   'Lentil',        '🫘'),
    'lentils':          IngredientHint('Masoor Daal',   'Masoor Daal',   'Lentil',        '🫘'),
    'red lentil':       IngredientHint('Masoor Daal',   'Masoor Daal',   'Lentil',        '🫘'),
    'yellow lentil':    IngredientHint('Moong Daal',    'Moong Daal',    'Lentil',        '🫘'),
    'chickpea':         IngredientHint('Chickpeas',     'Chana',         'Lentil',        '🫘'),
    'chickpeas':        IngredientHint('Chickpeas',     'Chana',         'Lentil',        '🫘'),
    'garbanzo':         IngredientHint('Chickpeas',     'Chana',         'Lentil',        '🫘'),
    'chana':            IngredientHint('Chickpeas',     'Chana',         'Lentil',        '🫘'),
    'kidney bean':      IngredientHint('Kidney Beans',  'Rajma',         'Lentil',        '🫘'),
    'kidney beans':     IngredientHint('Kidney Beans',  'Rajma',         'Lentil',        '🫘'),
    'rajma':            IngredientHint('Kidney Beans',  'Rajma',         'Lentil',        '🫘'),
    'black bean':       IngredientHint('Black Gram',    'Mash Daal',     'Lentil',        '🫘'),
    'black gram':       IngredientHint('Black Gram',    'Mash Daal',     'Lentil',        '🫘'),
    'mung':             IngredientHint('Moong Daal',    'Moong Daal',    'Lentil',        '🫘'),
    'mung bean':        IngredientHint('Moong Daal',    'Moong Daal',    'Lentil',        '🫘'),
    'moong':            IngredientHint('Moong Daal',    'Moong Daal',    'Lentil',        '🫘'),
    'split pea':        IngredientHint('Chana Daal',    'Chana Daal',    'Lentil',        '🫘'),
    'dal':              IngredientHint('Masoor Daal',   'Daal',          'Lentil',        '🫘'),
    'daal':             IngredientHint('Masoor Daal',   'Daal',          'Lentil',        '🫘'),
    'legume':           IngredientHint('Masoor Daal',   'Daal',          'Lentil',        '🫘'),
    'legumes':          IngredientHint('Masoor Daal',   'Daal',          'Lentil',        '🫘'),
    'bean':             IngredientHint('Mixed Beans',   'Phali',         'Lentil',        '🫘'),
    'beans':            IngredientHint('Mixed Beans',   'Phali',         'Lentil',        '🫘'),
    'soybean':          IngredientHint('Soybean',       'Soya',          'Lentil',        '🫘'),

    // ── SPICES ──────────────────────────────────────────────────────────────
    'garlic':           IngredientHint('Garlic',            'Lehsan',       'Spice', '🧄'),
    'ginger':           IngredientHint('Ginger',            'Adrak',        'Spice', '🫚'),
    'chili':            IngredientHint('Green Chili',       'Hari Mirch',   'Spice', '🌶️'),
    'chilli':           IngredientHint('Green Chili',       'Hari Mirch',   'Spice', '🌶️'),
    'chili pepper':     IngredientHint('Green Chili',       'Hari Mirch',   'Spice', '🌶️'),
    'green chili':      IngredientHint('Green Chili',       'Hari Mirch',   'Spice', '🌶️'),
    'red chili':        IngredientHint('Red Chili',         'Lal Mirch',    'Spice', '🌶️'),
    'red pepper':       IngredientHint('Red Chili',         'Lal Mirch',    'Spice', '🌶️'),
    'paprika':          IngredientHint('Paprika',           'Paprika',      'Spice', '🌶️'),
    'pepper':           IngredientHint('Black Pepper',      'Kali Mirch',   'Spice', '⚫'),
    'black pepper':     IngredientHint('Black Pepper',      'Kali Mirch',   'Spice', '⚫'),
    'white pepper':     IngredientHint('White Pepper',      'Safed Mirch',  'Spice', '⚪'),
    'cumin':            IngredientHint('Cumin',             'Zeera',        'Spice', '🌿'),
    'caraway':          IngredientHint('Cumin',             'Zeera',        'Spice', '🌿'),
    'coriander':        IngredientHint('Coriander Powder',  'Dhania',       'Spice', '🌿'),
    'coriander seed':   IngredientHint('Coriander Powder',  'Dhania',       'Spice', '🌿'),
    'turmeric':         IngredientHint('Turmeric',          'Haldi',        'Spice', '🟡'),
    'cardamom':         IngredientHint('Cardamom',          'Elaichi',      'Spice', '🌿'),
    'cinnamon':         IngredientHint('Cinnamon',          'Dalchini',     'Spice', '🟤'),
    'clove':            IngredientHint('Cloves',            'Laung',        'Spice', '🟤'),
    'cloves':           IngredientHint('Cloves',            'Laung',        'Spice', '🟤'),
    'bay leaf':         IngredientHint('Bay Leaf',          'Tej Patta',    'Spice', '🌿'),
    'star anise':       IngredientHint('Star Anise',        'Badiyan',      'Spice', '⭐'),
    'anise':            IngredientHint('Star Anise',        'Badiyan',      'Spice', '⭐'),
    'fennel':           IngredientHint('Fennel',            'Saunf',        'Spice', '🌿'),
    'mustard':          IngredientHint('Mustard Seeds',     'Sarson',       'Spice', '🌿'),
    'mustard seed':     IngredientHint('Mustard Seeds',     'Sarson',       'Spice', '🌿'),
    'fenugreek':        IngredientHint('Fenugreek',         'Methi',        'Spice', '🌿'),
    'nutmeg':           IngredientHint('Nutmeg',            'Jaifal',       'Spice', '🟤'),
    'mace':             IngredientHint('Mace',              'Javitri',      'Spice', '🟤'),
    'saffron':          IngredientHint('Saffron',           'Zafran',       'Spice', '🟡'),
    'spice':            IngredientHint('Garam Masala',      'Masala',       'Spice', '🌶️'),
    'masala':           IngredientHint('Garam Masala',      'Garam Masala', 'Spice', '🌶️'),
    'allspice':         IngredientHint('Garam Masala',      'Garam Masala', 'Spice', '🌶️'),
    'seasoning':        IngredientHint('Garam Masala',      'Masala',       'Spice', '🌶️'),

    // ── HERBS ───────────────────────────────────────────────────────────────
    'mint':             IngredientHint('Mint',           'Podina',        'Herb',          '🌿'),
    'cilantro':         IngredientHint('Fresh Coriander','Hara Dhania',   'Herb',          '🌿'),
    'coriander leaf':   IngredientHint('Fresh Coriander','Hara Dhania',   'Herb',          '🌿'),
    'coriander leaves': IngredientHint('Fresh Coriander','Hara Dhania',   'Herb',          '🌿'),
    'curry leaf':       IngredientHint('Curry Leaves',   'Curry Patta',   'Herb',          '🌿'),
    'curry leaves':     IngredientHint('Curry Leaves',   'Curry Patta',   'Herb',          '🌿'),
    'basil':            IngredientHint('Basil',          'Basil',         'Herb',          '🌿'),
    'parsley':          IngredientHint('Parsley',        'Parsley',       'Herb',          '🌿'),
    'thyme':            IngredientHint('Thyme',          'Thyme',         'Herb',          '🌿'),
    'oregano':          IngredientHint('Oregano',        'Oregano',       'Herb',          '🌿'),
    'rosemary':         IngredientHint('Rosemary',       'Rosemary',      'Herb',          '🌿'),
    'dill':             IngredientHint('Dill',           'Soya Saag',     'Herb',          '🌿'),
    'herb':             IngredientHint('Fresh Herbs',    'Saag',          'Herb',          '🌿'),

    // ── OILS & FATS ─────────────────────────────────────────────────────────
    'oil':              IngredientHint('Cooking Oil',    'Khana Pakane Ka Tel', 'Oil & Fat','🫙'),
    'cooking oil':      IngredientHint('Cooking Oil',    'Tel',           'Oil & Fat',     '🫙'),
    'vegetable oil':    IngredientHint('Cooking Oil',    'Tel',           'Oil & Fat',     '🫙'),
    'sunflower oil':    IngredientHint('Cooking Oil',    'Tel',           'Oil & Fat',     '🫙'),
    'canola oil':       IngredientHint('Cooking Oil',    'Tel',           'Oil & Fat',     '🫙'),
    'olive oil':        IngredientHint('Olive Oil',      'Zaitoon Tel',   'Oil & Fat',     '🫙'),
    'ghee':             IngredientHint('Ghee',           'Ghee',          'Oil & Fat',     '🫙'),
    'clarified butter': IngredientHint('Ghee',           'Ghee',          'Oil & Fat',     '🫙'),
    'margarine':        IngredientHint('Butter',         'Makhan',        'Oil & Fat',     '🧈'),
    'shortening':       IngredientHint('Cooking Oil',    'Tel',           'Oil & Fat',     '🫙'),

    // ── CONDIMENTS & SAUCES ────────────────────────────────────────────────
    'salt':             IngredientHint('Salt',           'Namak',         'Condiment',     '🧂'),
    'rock salt':        IngredientHint('Salt',           'Namak',         'Condiment',     '🧂'),
    'vinegar':          IngredientHint('Vinegar',        'Sirka',         'Condiment',     '🫙'),
    'soy sauce':        IngredientHint('Soy Sauce',      'Soy Sauce',     'Condiment',     '🫙'),
    'ketchup':          IngredientHint('Ketchup',        'Ketchup',       'Condiment',     '🍅'),
    'sauce':            IngredientHint('Sauce',          'Chatni',        'Condiment',     '🫙'),
    'chutney':          IngredientHint('Chutney',        'Chatni',        'Condiment',     '🫙'),
    'tamarind':         IngredientHint('Tamarind',       'Imli',          'Condiment',     '🟫'),
    'hot sauce':        IngredientHint('Green Chili',    'Hari Mirch',    'Condiment',     '🌶️'),
    'tomato paste':     IngredientHint('Tomato',         'Tamatar',       'Condiment',     '🍅'),
    'tomato sauce':     IngredientHint('Tomato',         'Tamatar',       'Condiment',     '🍅'),
    'mayonnaise':       IngredientHint('Mayonnaise',     'Mayonnaise',    'Condiment',     '🫙'),
    'mustard sauce':    IngredientHint('Mustard',        'Sarson',        'Condiment',     '🫙'),
    'relish':           IngredientHint('Chutney',        'Chatni',        'Condiment',     '🫙'),

    // ── NUTS & DRY FRUITS ───────────────────────────────────────────────────
    'almond':           IngredientHint('Almonds',        'Badam',         'Nut & Dry Fruit','🥜'),
    'almonds':          IngredientHint('Almonds',        'Badam',         'Nut & Dry Fruit','🥜'),
    'pistachio':        IngredientHint('Pistachios',     'Pista',         'Nut & Dry Fruit','🥜'),
    'pistachios':       IngredientHint('Pistachios',     'Pista',         'Nut & Dry Fruit','🥜'),
    'cashew':           IngredientHint('Cashews',        'Kaju',          'Nut & Dry Fruit','🥜'),
    'cashews':          IngredientHint('Cashews',        'Kaju',          'Nut & Dry Fruit','🥜'),
    'walnut':           IngredientHint('Walnuts',        'Akhrot',        'Nut & Dry Fruit','🥜'),
    'walnuts':          IngredientHint('Walnuts',        'Akhrot',        'Nut & Dry Fruit','🥜'),
    'peanut':           IngredientHint('Peanuts',        'Moong Phali',   'Nut & Dry Fruit','🥜'),
    'peanuts':          IngredientHint('Peanuts',        'Moong Phali',   'Nut & Dry Fruit','🥜'),
    'hazelnut':         IngredientHint('Hazelnuts',      'Hazelnut',      'Nut & Dry Fruit','🥜'),
    'pine nut':         IngredientHint('Pine Nuts',      'Chilgoza',      'Nut & Dry Fruit','🥜'),
    'raisin':           IngredientHint('Raisins',        'Kishmish',      'Nut & Dry Fruit','🍇'),
    'raisins':          IngredientHint('Raisins',        'Kishmish',      'Nut & Dry Fruit','🍇'),
    'date':             IngredientHint('Dates',          'Khajoor',       'Nut & Dry Fruit','🟫'),
    'dates':            IngredientHint('Dates',          'Khajoor',       'Nut & Dry Fruit','🟫'),
    'dried fruit':      IngredientHint('Dry Fruits',     'Dry Fruits',    'Nut & Dry Fruit','🥜'),
    'nut':              IngredientHint('Mixed Nuts',     'Dry Fruits',    'Nut & Dry Fruit','🥜'),
    'nuts':             IngredientHint('Mixed Nuts',     'Dry Fruits',    'Nut & Dry Fruit','🥜'),

    // ── SWEETENERS ──────────────────────────────────────────────────────────
    'sugar':            IngredientHint('Sugar',          'Cheeni',        'Sweetener',     '🍬'),
    'white sugar':      IngredientHint('Sugar',          'Cheeni',        'Sweetener',     '🍬'),
    'brown sugar':      IngredientHint('Brown Sugar',    'Brown Cheeni',  'Sweetener',     '🍬'),
    'honey':            IngredientHint('Honey',          'Shahad',        'Sweetener',     '🍯'),
    'jaggery':          IngredientHint('Jaggery',        'Gur',           'Sweetener',     '🟤'),
    'molasses':         IngredientHint('Jaggery',        'Gur',           'Sweetener',     '🟤'),
    'syrup':            IngredientHint('Sugar Syrup',    'Chasni',        'Sweetener',     '🍯'),
    'maple syrup':      IngredientHint('Sugar Syrup',    'Chasni',        'Sweetener',     '🍯'),
    'stevia':           IngredientHint('Sugar',          'Cheeni',        'Sweetener',     '🍬'),
    'confectionery':    IngredientHint('Sugar',          'Cheeni',        'Sweetener',     '🍬'),

    // ── BEVERAGES ───────────────────────────────────────────────────────────
    'tea':              IngredientHint('Tea',            'Chai',          'Beverage',      '🍵'),
    'green tea':        IngredientHint('Tea',            'Chai',          'Beverage',      '🍵'),
    'coffee':           IngredientHint('Coffee',         'Coffee',        'Beverage',      '☕'),
    'juice':            IngredientHint('Juice',          'Juice',         'Beverage',      '🍹'),
    'water':            IngredientHint('Water',          'Pani',          'Beverage',      '💧'),
    'soft drink':       IngredientHint('Cold Drink',     'Cold Drink',    'Beverage',      '🥤'),
    'soda':             IngredientHint('Cold Drink',     'Cold Drink',    'Beverage',      '🥤'),
  };

  // ── Smart 4-strategy lookup ──────────────────────────────────────────────
  static IngredientHint? matchLabel(String rawLabel) {
    final key = rawLabel.trim().toLowerCase();

    // Strategy 1 — exact match
    if (_map.containsKey(key)) return _map[key];

    // Strategy 2 — all known keys that the label contains, or that contain the label
    for (final entry in _map.entries) {
      if (key == entry.key) return entry.value;
    }

    // Strategy 3 — substring: label contains key OR key contains label
    for (final entry in _map.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }

    // Strategy 4 — token matching: split multi-word label and try each word
    final tokens = key.split(RegExp(r'[\s\-_/]+'));
    if (tokens.length > 1) {
      for (final token in tokens) {
        if (token.length < 3) continue; // skip tiny words like "of", "a"
        if (_map.containsKey(token)) return _map[token];
        for (final entry in _map.entries) {
          if (token.contains(entry.key) || entry.key.contains(token)) {
            return entry.value;
          }
        }
      }
    }

    return null;
  }
}

class DetectedIngredient {
  final String nameEn;
  final String nameUr;
  final String category;
  final String icon;
  final double confidence;

  const DetectedIngredient({
    required this.nameEn,
    required this.nameUr,
    required this.category,
    required this.icon,
    required this.confidence,
  });
}
