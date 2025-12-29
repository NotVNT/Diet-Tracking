#!/usr/bin/env python3
"""
Food Recommendation System - Demo Script

This script demonstrates various recommendation algorithms using the imported Neo4j data.
"""

from neo4j import GraphDatabase
import json

class FoodRecommendationDemo:
    def __init__(self, uri=None, username=None, password=None):
        import os
        uri = uri or os.getenv('NEO4J_URI', 'bolt://localhost:7687')
        username = username or os.getenv('NEO4J_USERNAME', 'neo4j')
        password = password or os.getenv('NEO4J_PASSWORD', 'foodrecommendation123')
        try:
            self.driver = GraphDatabase.driver(uri, auth=(username, password))
            # Test connection
            with self.driver.session() as session:
                session.run("RETURN 1")
            print("✅ Connected to Neo4j successfully!")
        except Exception as e:
            print(f"❌ Failed to connect to Neo4j: {e}")
            print("Please make sure Neo4j is running and credentials are correct.")
            self.driver = None
    
    def close(self):
        if self.driver:
            self.driver.close()
    
    def get_popular_recipes(self, limit=10):
        """Get most popular recipes by rating"""
        if self.driver is None:
            print("❌ No database connection.")
            return
        try:
            with self.driver.session() as session:
                result = session.run("""
                    MATCH (r:Recipe)
                    WHERE r.rating_value > 0
                    RETURN r.title, r.rating_value, r.recipe_cuisine, r.cook_time
                    ORDER BY r.rating_value DESC
                    LIMIT $limit
                """, limit=limit)
                
                print("🍽️  TOP RATED RECIPES")
                print("=" * 60)
                count = 0
                for record in result:
                    print(f"⭐ {record['r.rating_value']} - {record['r.title']}")
                    print(f"   Cuisine: {record['r.recipe_cuisine']} | Time: {record['r.cook_time']}")
                    print()
                    count += 1
                if count == 0:
                    print("No recipes found. Please check if data is imported.")
        except Exception as e:
            print(f"❌ Error getting popular recipes: {e}")
    
    def get_recipes_by_ingredient(self, ingredient_name, limit=5):
        """Find recipes containing a specific ingredient"""
        if self.driver is None:
            print("❌ No database connection.")
            return
        try:
            with self.driver.session() as session:
                result = session.run("""
                    MATCH (r:Recipe)-[:CONTAINS]->(i:Ingredient {name: $ingredient})
                    RETURN r.title, r.rating_value, r.recipe_cuisine
                    ORDER BY r.rating_value DESC
                    LIMIT $limit
                """, ingredient=ingredient_name.lower(), limit=limit)
                
                print(f"🥘 RECIPES WITH {ingredient_name.upper()}")
                print("=" * 60)
                count = 0
                for record in result:
                    print(f"⭐ {record['r.rating_value']} - {record['r.title']}")
                    print(f"   Cuisine: {record['r.recipe_cuisine']}")
                    print()
                    count += 1
                if count == 0:
                    print(f"No recipes found with ingredient '{ingredient_name}'. Please check the ingredient name or data.")
        except Exception as e:
            print(f"❌ Error getting recipes by ingredient: {e}")
    
    def collaborative_filtering(self, user_id, limit=5):
        """Find recipes liked by users with similar tastes"""
        with self.driver.session() as session:
            result = session.run("""
                MATCH (u1:User {user_id: $user_id})-[:LIKES]->(r1:Recipe)<-[:LIKES]-(u2:User)
                WHERE u1 <> u2
                WITH u2, count(r1) as common_recipes
                ORDER BY common_recipes DESC
                LIMIT 3
                MATCH (u2)-[:LIKES]->(r2:Recipe)
                WHERE NOT (u1:User {user_id: $user_id})-[:LIKES]->(r2)
                RETURN r2.title, r2.rating_value, r2.recipe_cuisine
                ORDER BY r2.rating_value DESC
                LIMIT $limit
            """, user_id=user_id, limit=limit)
            
            print(f"👥 COLLABORATIVE FILTERING FOR USER {user_id}")
            print("=" * 60)
            for record in result:
                print(f"⭐ {record['r2.rating_value']} - {record['r2.title']}")
                print(f"   Cuisine: {record['r2.recipe_cuisine']}")
                print()
    
    def ingredient_based_recommendations(self, recipe_id, limit=5):
        """Find recipes with similar ingredients"""
        if self.driver is None:
            print("❌ No database connection.")
            return
        try:
            with self.driver.session() as session:
                result = session.run("""
                    MATCH (r1:Recipe {recipe_id: $recipe_id})-[:CONTAINS]->(i:Ingredient)<-[:CONTAINS]-(r2:Recipe)
                    WHERE r1 <> r2
                    WITH r2, count(i) as common_ingredients
                    ORDER BY common_ingredients DESC, r2.rating_value DESC
                    RETURN r2.title, common_ingredients, r2.rating_value, r2.recipe_cuisine
                    LIMIT $limit
                """, recipe_id=recipe_id, limit=limit)
                
                print(f"🔗 SIMILAR RECIPES TO {recipe_id}")
                print("=" * 60)
                count = 0
                for record in result:
                    print(f"⭐ {record['r2.rating_value']} - {record['r2.title']}")
                    print(f"   Common ingredients: {record['common_ingredients']} | Cuisine: {record['r2.recipe_cuisine']}")
                    print()
                    count += 1
                if count == 0:
                    print(f"No similar recipes found for '{recipe_id}'. Recipe may not exist or have no similar recipes.")
        except Exception as e:
            print(f"❌ Error in ingredient-based recommendations: {e}")
    
    def cuisine_recommendations(self, cuisine, limit=5):
        """Find top recipes by cuisine"""
        if self.driver is None:
            print("❌ No database connection.")
            return
        try:
            with self.driver.session() as session:
                result = session.run("""
                    MATCH (r:Recipe)
                    WHERE toLower(r.recipe_cuisine) CONTAINS toLower($cuisine)
                    RETURN r.title, r.rating_value, r.cook_time
                    ORDER BY r.rating_value DESC
                    LIMIT $limit
                """, cuisine=cuisine, limit=limit)
                
                print(f"🌍 TOP {cuisine.upper()} RECIPES")
                print("=" * 60)
                count = 0
                for record in result:
                    print(f"⭐ {record['r.rating_value']} - {record['r.title']}")
                    print(f"   Time: {record['r.cook_time']}")
                    print()
                    count += 1
                if count == 0:
                    print(f"No recipes found for cuisine '{cuisine}'. Please check the cuisine name or data.")
        except Exception as e:
            print(f"❌ Error getting cuisine recommendations: {e}")
    
    def get_user_preferences(self, user_id):
        """Show user's preferences and liked recipes"""
        if self.driver is None:
            print("❌ No database connection.")
            return
        try:
            with self.driver.session() as session:
                # Get user info
                user_info = session.run("""
                    MATCH (u:User {user_id: $user_id})
                    RETURN u.full_name, u.favorite_cuisines, u.cooking_skill
                """, user_id=user_id).single()
                
                if user_info:
                    print(f"👤 USER PROFILE: {user_info['u.full_name']}")
                    print("=" * 60)
                    print(f"Favorite cuisines: {user_info['u.favorite_cuisines']}")
                    print(f"Cooking skill: {user_info['u.cooking_skill']}")
                    print()
                else:
                    print(f"User '{user_id}' not found.")
                    return
                
                # Get liked recipes
                result = session.run("""
                    MATCH (u:User {user_id: $user_id})-[:LIKES]->(r:Recipe)
                    RETURN r.title, r.rating_value, r.recipe_cuisine
                    ORDER BY r.rating_value DESC
                """, user_id=user_id)
                
                print("❤️  LIKED RECIPES")
                print("=" * 60)
                count = 0
                for record in result:
                    print(f"⭐ {record['r.rating_value']} - {record['r.title']}")
                    print(f"   Cuisine: {record['r.recipe_cuisine']}")
                    print()
                    count += 1
                if count == 0:
                    print("No liked recipes found for this user.")
        except Exception as e:
            print(f"❌ Error getting user preferences: {e}")
    
    def run_demo(self):
        """Run a complete demo of the recommendation system"""
        if self.driver is None:
            print("❌ Cannot run demo: No database connection.")
            return
        
        print("🍳 FOOD RECOMMENDATION SYSTEM DEMO")
        print("=" * 80)
        print()
        
        # Show popular recipes
        self.get_popular_recipes(5)
        
        # Show recipes by ingredient
        self.get_recipes_by_ingredient("garlic", 3)
        
        # Show cuisine recommendations
        self.get_recipes_by_ingredient("chicken", 3)
        
        # Show user preferences (if any demo users exist)
        try:
            with self.driver.session() as session:
                demo_users = session.run("""
                    MATCH (u:User)
                    WHERE u.user_id STARTS WITH 'demo_user'
                    RETURN u.user_id, u.full_name
                    LIMIT 1
                """).single()
                
                if demo_users:
                    self.get_user_preferences(demo_users['u.user_id'])
                    self.collaborative_filtering(demo_users['u.user_id'], 3)
                else:
                    print("👤 No demo users found in database.")
        except Exception as e:
            print(f"❌ Error checking for demo users: {e}")
        
        # Show ingredient-based recommendations
        try:
            with self.driver.session() as session:
                sample_recipe = session.run("""
                    MATCH (r:Recipe)
                    WHERE r.rating_value > 4.5
                    RETURN r.recipe_id, r.title
                    LIMIT 1
                """).single()
                
                if sample_recipe:
                    print(f"📝 Sample recipe: {sample_recipe['r.title']}")
                    self.ingredient_based_recommendations(sample_recipe['r.recipe_id'], 3)
                else:
                    print("📝 No high-rated recipes found for ingredient-based recommendations.")
        except Exception as e:
            print(f"❌ Error finding sample recipe: {e}")
        
        # Show cuisine recommendations
        self.cuisine_recommendations("Italian", 3)
        
        print("🎉 Demo completed! The system is ready for advanced recommendations.")
        print("💡 Try accessing Neo4j Browser at http://localhost:7474 for more queries!")

def main():
    demo = FoodRecommendationDemo()
    try:
        demo.run_demo()
    finally:
        demo.close()

if __name__ == "__main__":
    main()