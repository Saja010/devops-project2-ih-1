-- Sample data for Burger Builder application (PostgreSQL)
-- Only insert data if table is empty (one-time initialization)

-- Insert only if table is empty
INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Classic Sesame Bun', 'buns', 1.50, 'Fresh sesame seed bun', '/images/buns/sesame-bun.jpg', TRUE, 1
WHERE NOT EXISTS (SELECT 1 FROM ingredients LIMIT 1);

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Whole Wheat Bun', 'buns', 1.75, 'Healthy whole wheat bun', '/images/buns/whole-wheat-bun.jpg', TRUE, 2
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Whole Wheat Bun');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Brioche Bun', 'buns', 2.00, 'Rich and buttery brioche bun', '/images/buns/brioche-bun.jpg', TRUE, 3
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Brioche Bun');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Gluten-Free Bun', 'buns', 2.25, 'Gluten-free alternative bun', '/images/buns/gluten-free-bun.jpg', TRUE, 4
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Gluten-Free Bun');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Beef Patty', 'patties', 4.50, 'Juicy 100% beef patty', '/images/patties/beef-patty.jpg', TRUE, 1
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Beef Patty');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Chicken Breast', 'patties', 4.25, 'Grilled chicken breast', '/images/patties/chicken-breast.jpg', TRUE, 2
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Chicken Breast');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Turkey Patty', 'patties', 4.00, 'Lean turkey patty', '/images/patties/turkey-patty.jpg', TRUE, 3
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Turkey Patty');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Veggie Patty', 'patties', 3.75, 'Plant-based veggie patty', '/images/patties/veggie-patty.jpg', TRUE, 4
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Veggie Patty');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Salmon Patty', 'patties', 5.50, 'Fresh salmon patty', '/images/patties/salmon-patty.jpg', TRUE, 5
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Salmon Patty');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Lettuce', 'toppings', 0.50, 'Fresh crisp lettuce', '/images/toppings/lettuce.jpg', TRUE, 1
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Lettuce');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Tomato', 'toppings', 0.75, 'Fresh tomato slices', '/images/toppings/tomato.jpg', TRUE, 2
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Tomato');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Onion', 'toppings', 0.50, 'Raw or grilled onions', '/images/toppings/onion.jpg', TRUE, 3
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Onion');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Pickles', 'toppings', 0.50, 'Dill pickle slices', '/images/toppings/pickles.jpg', TRUE, 4
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Pickles');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Mushrooms', 'toppings', 1.00, 'Sautéed mushrooms', '/images/toppings/mushrooms.jpg', TRUE, 5
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Mushrooms');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Bacon', 'toppings', 1.50, 'Crispy bacon strips', '/images/toppings/bacon.jpg', TRUE, 6
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Bacon');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Avocado', 'toppings', 1.25, 'Fresh avocado slices', '/images/toppings/avocado.jpg', TRUE, 7
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Avocado');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Jalapeños', 'toppings', 0.75, 'Spicy jalapeño peppers', '/images/toppings/jalapenos.jpg', TRUE, 8
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Jalapeños');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Ketchup', 'sauces', 0.25, 'Classic tomato ketchup', '/images/sauces/ketchup.jpg', TRUE, 1
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Ketchup');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Mustard', 'sauces', 0.25, 'Yellow mustard', '/images/sauces/mustard.jpg', TRUE, 2
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Mustard');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Mayo', 'sauces', 0.25, 'Creamy mayonnaise', '/images/sauces/mayo.jpg', TRUE, 3
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Mayo');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'BBQ Sauce', 'sauces', 0.50, 'Smoky BBQ sauce', '/images/sauces/bbq-sauce.jpg', TRUE, 4
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'BBQ Sauce');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Ranch', 'sauces', 0.50, 'Creamy ranch dressing', '/images/sauces/ranch.jpg', TRUE, 5
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Ranch');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Sriracha', 'sauces', 0.50, 'Spicy sriracha sauce', '/images/sauces/sriracha.jpg', TRUE, 6
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Sriracha');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Aioli', 'sauces', 0.75, 'Garlic aioli', '/images/sauces/aioli.jpg', TRUE, 7
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Aioli');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Buffalo Sauce', 'sauces', 0.50, 'Spicy buffalo sauce', '/images/sauces/buffalo-sauce.jpg', TRUE, 8
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'Buffalo Sauce');
